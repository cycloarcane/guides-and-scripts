# Implementing MCP-Compatible OSINT Tools in TypeScript

This guide walks through converting Python-based OSINT tools into **TypeScript** MCP servers that work with MCPO and Open WebUI. We will cover project setup, using FastMCP patterns in TypeScript, code examples for each tool (Link Follower, DuckDuckGo search, Email, Username, Phone OSINT), and important considerations like CLI integration, typing dynamic JSON, Open WebUI’s WebSocket support, and debugging. By the end, you’ll have a clear roadmap to implement MCP-compatible tools in TS and serve them via MCPO.

## Project Setup and Configuration

Before coding, set up a proper TypeScript project environment:

* **Node.js**: Use a modern LTS version (Node 18+). This ensures support for ES2020+ features and stable libraries.

* **Initialize Project**: Run `npm init -y` to create a package.json. Install required packages with `npm install`. Key dependencies include:

  * `fastmcp` – TypeScript framework for MCP servers.
  * HTTP & HTML parsing libs: e.g. `axios` (for HTTP requests) and `cheerio` (for HTML parsing).
  * OSINT-specific libs (optional): e.g. `duckduckgo-search` for DDG queries, or you can use native HTTP calls.
  * Dev dependencies: `typescript`, `ts-node` (optional for running TS directly), `@types/node` (Node.js type definitions), etc.

* **Project Structure**: Mirror the Python layout for clarity. For example:

  ```
  OSINT/             # source code for OSINT tools
    link_follower_osint.ts
    duckduckgo_osint.ts
    email_osint.ts
    username_osint.ts
    phone_osint.ts
  tsconfig.json
  package.json
  ```

  Each tool’s TS file will produce a JS output in `dist/OSINT/` after compilation.

* **TypeScript Config** (`tsconfig.json`): Configure compilation for Node:

  ```json
  {
    "compilerOptions": {
      "target": "ES2020",
      "module": "CommonJS",
      "outDir": "dist",
      "rootDir": ".",
      "strict": true,
      "esModuleInterop": true
    },
    "include": ["OSINT/**/*.ts"]
  }
  ```

  This targets modern ECMAScript, outputs CommonJS modules (for Node), and enables strict type checking. Adjust `rootDir`/`outDir` as needed.

* **Node Version & Transpilation**: Ensure the Node version supports your `target`. For Node 18+, ES2020 is fine. If using newer syntax, you might target ES2022 or later (Node 20). The above config produces JavaScript in `dist/` that Node will execute.

* **Build Script**: Add an NPM script to compile TS:

  ```json
  "scripts": {
    "build": "tsc",
    "start": "npm run build && mcpo"
  }
  ```

  Running `npm run build` generates the `dist/OSINT/*.js` files used by MCPO.

## FastMCP in TypeScript: Tool Server Basics

FastMCP provides a convenient pattern for MCP servers in both Python and TypeScript. In TypeScript, you’ll use the `fastmcp` NPM package, which offers a similar API for defining tools. The MCP server will use **STDIO transport** when run under MCPO, meaning it reads JSON from stdin and writes JSON responses to stdout. FastMCP abstracts this for you.

**Key Pattern:** Create a FastMCP server instance and register tools (endpoints) with it, then start the server on the appropriate transport. Each “tool” corresponds to a function you expose (like `fetch_url` or `search_username`). FastMCP uses the tool definitions to auto-generate schemas (for OpenAPI via MCPO) and handle input/output.

Below is a **simplified example** of an MCP server in TypeScript with one dummy tool, illustrating the structure:

```ts
import { FastMCP } from "fastmcp";
import { z } from "zod";  // for input schema

const server = new FastMCP({ name: "demo_server", version: "1.0.0" });

// Define a tool (function) to be exposed
server.addTool({
  name: "add",
  description: "Add two numbers",
  parameters: z.object({
    a: z.number(),
    b: z.number()
  }),
  execute: async (args) => {
    const sum = args.a + args.b;
    return String(sum);  // convert result to string (MCP expects stringifiable result)
  }
});

// Start the server (stdio transport for MCPO/CLI)
server.start({ transportType: "stdio" });
```

This registers an `add` tool and starts the MCP server. The `fastmcp` framework will handle JSON I/O over stdio automatically. In our OSINT tools, we’ll use the same pattern: one FastMCP server per file, with multiple tools added as needed.

**Using Zod for Parameters:** We use `zod` (or a similar schema library) to define the tool’s expected parameters and types. This is analogous to Python’s type hints/docstrings used by FastMCP. The schema ensures proper typing and helps MCPO generate the OpenAPI spec for the tool. If you prefer not to use Zod, you can still define parameters in a simpler way, but Zod is recommended for idiomatic usage and input validation.

**Output**: The `execute` function returns the result (which can be a string, number, boolean, or an object/array that can be JSON-serialized). We will typically return JSON objects (as in the Python versions) to convey structured OSINT results.

With these basics in mind, let’s implement each tool in TypeScript.

## Implementing the OSINT Tools in TypeScript

Each OSINT tool corresponds to a Python script we want to replicate in TS. The major difference is how we perform certain tasks (like HTTP requests or calling external CLI tools) in Node.js. We’ll cover each tool, showing code snippets and explanations:

### 1. Link Follower OSINT (Web Content Fetcher)

**Purpose:** Fetch a web page’s content and extract data (text, title, links, metadata). In Python this used `requests` + BeautifulSoup. In TS, we’ll use `axios` (HTTP client) and `cheerio` (jQuery-like HTML parser).

**Challenges & Approach:**

* Perform HTTP GET with a custom User-Agent.
* Limit content size (stop if too large).
* Parse HTML to extract title, clean text content, links (with normalization), and meta tags.
* Implement a simple rate-limit between requests (delay) to avoid hammering servers.
* Provide two tools: `fetch_url` (single page) and `fetch_multiple_urls`.

**TypeScript Code Example (link\_follower\_osint.ts):**

```ts
import { FastMCP } from "fastmcp";
import axios from "axios";
import * as cheerio from "cheerio";

const server = new FastMCP({ name: "link_follower", version: "1.0.0" });

// Configurable constants
const USER_AGENT = "Mozilla/5.0 (compatible; OSINT-Bot/1.0)";
let lastFetchTime = 0;

// Simple rate limiter to enforce delay between requests
function rateLimit(delaySec: number) {
  const now = Date.now();
  const waitTime = lastFetchTime + delaySec*1000 - now;
  if (waitTime > 0) {
    Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, waitTime);  // or use setTimeout in async context
  }
  lastFetchTime = Date.now();
}

// Utility: Validate URL format
function isValidUrl(url: string): boolean {
  try {
    const u = new URL(url);
    return (u.protocol === "http:" || u.protocol === "https:") && !!u.host;
  } catch {
    return false;
  }
}

// Utility: Extract text content from HTML (remove scripts/styles and collapse whitespace)
function extractTextContent($: cheerio.CheerioAPI): string {
  $("script, style, header, footer, nav").remove();
  let text = $.text();
  text = text.replace(/\s+/g, " ").trim();
  return text;
}

// Utility: Extract and normalize links from HTML
function extractLinks($: cheerio.CheerioAPI, baseUrl: string) {
  const links: { href: string; text: string }[] = [];
  $("a[href]").each((_, elem) => {
    const href = new URL($(elem).attr("href")!, baseUrl).href;  // resolve relative URL
    const text = $(elem).text().trim() || href;
    links.push({ href, text });
  });
  return links;
}

// Utility: Extract meta tags (name/content or property/content)
function extractMetadata($: cheerio.CheerioAPI) {
  const metadata: Record<string, string> = {};
  $('meta[name], meta[property]').each((_, elem) => {
    const name = $(elem).attr("name") || $(elem).attr("property");
    const content = $(elem).attr("content");
    if (name && content) {
      metadata[name] = content;
    }
  });
  return metadata;
}

// Tool 1: Fetch single URL
server.addTool({
  name: "fetch_url",
  description: "Fetch and parse content from a single URL",
  parameters: { /* define similar to Python args, or use z.object as above */ },
  execute: async (args) => {
    const { url, delay = 3.0, timeout = 30, max_content_length = 1000000,
            extract_text = true, extract_links = true, extract_metadata = true } = args;
    if (!isValidUrl(url)) {
      return { status: "error", url, message: "Invalid or unsupported URL format" };
    }
    rateLimit(delay);
    try {
      const resp = await axios.get(url, {
        headers: { "User-Agent": USER_AGENT },
        timeout: timeout * 1000,
        responseType: "arraybuffer"  // get raw data to check length
      });
      const contentType = resp.headers["content-type"]?.toLowerCase() || "";
      const contentLength = Number(resp.headers["content-length"] || 0);
      if (contentLength && contentLength > max_content_length) {
        return {
          status: "error", url,
          message: `Content too large: ${contentLength} bytes (max: ${max_content_length})`
        };
      }
      // Handle non-HTML content
      if (!contentType.includes("text/html") && !contentType.includes("application/xhtml")) {
        if (contentType.startsWith("text/")) {
          // Return plain text content (truncate to max_content_length)
          const textData = resp.data.toString("utf-8");
          return {
            status: "success", url, content_type: contentType,
            text_content: textData.slice(0, max_content_length)
          };
        } else {
          // Binary content (images, PDFs, etc.)
          return {
            status: "success", url, content_type: contentType,
            message: `Non-HTML content: ${contentType}`
          };
        }
      }
      // If HTML content:
      // Convert buffer to string (assuming UTF-8)
      const html = resp.data.toString("utf-8");
      const $ = cheerio.load(html);
      const result: any = {
        status: "success",
        url,
        content_type: contentType,
        title: $("head > title").text().trim() || ""
      };
      if (extract_text) {
        result.text_content = extractTextContent($);
      }
      if (extract_links) {
        result.links = extractLinks($, url);
      }
      if (extract_metadata) {
        result.metadata = extractMetadata($);
      }
      return result;
    } catch (err: any) {
      if (err.code === 'ECONNABORTED') {
        return { status: "error", url, message: "Request timed out" };
      }
      if (err.response) {
        // HTTP error
        return { status: "error", url, message: `HTTP error: ${err.response.status}` };
      }
      return { status: "error", url, message: `Request failed: ${err.message}` };
    }
  }
});

// Tool 2: Fetch multiple URLs (calls fetch_url for each, up to max_urls)
server.addTool({
  name: "fetch_multiple_urls",
  description: "Fetch and parse content from multiple URLs",
  parameters: { /* urls list and same options as fetch_url */ },
  execute: async (args) => {
    const { urls, max_urls = 10, ...options } = args;
    if (!urls || urls.length === 0) {
      return { status: "error", message: "No URLs provided" };
    }
    const toProcess = urls.slice(0, max_urls);
    const results = [];
    for (const u of toProcess) {
      // Reuse fetch_url logic by calling the tool function directly:
      const res = await server.callTool("fetch_url", { url: u, ...options });
      results.push(res);
    }
    return {
      status: "success",
      total_urls: urls.length,
      processed_urls: toProcess.length,
      results
    };
  }
});

server.start({ transportType: "stdio" });
```

**Explanation:**

* We define the `fetch_url` tool’s `execute` as an `async` function performing an HTTP GET via axios. We check content length and type before parsing to avoid downloading huge files.
* Cheerio is used to parse HTML and extract required fields (title, links, metadata, text).
* The output is assembled as a JSON object with fields identical to the Python version (status, url, content\_type, title, text\_content, links, metadata, etc.).
* `fetch_multiple_urls` simply iterates through a list and calls `fetch_url` for each (throttling is respected inside `fetch_url`). We could also parallelize these calls with `Promise.all` if concurrency is desired, but be mindful of rate limiting and target server load.
* Rate limiting is done via a simple global timestamp check. In Node, we don’t have `time.sleep`, so we use a workaround. Above, `Atomics.wait` is shown (which blocks the thread for the given duration). In an async context, a more graceful approach is using `await new Promise(res => setTimeout(res, waitTime))`. Choose one approach (the `Atomics.wait` is a hack; using `setTimeout` in `async` is recommended for clarity).

This TS implementation closely mirrors the Python logic. The result JSON structure is the same, which is important for consistency in Open WebUI.

### 2. DuckDuckGo Search OSINT

**Purpose:** Perform a web search via DuckDuckGo and return a list of results (title, URL, snippet). The Python tool used the `duckduckgo_search` library (which scraped results through DDG’s HTML or API). In Node, we have a few options:

* Use an NPM library (e.g. `duckduckgo-search` which provides async iterators for results, similar to the Python library).
* Use an unofficial HTTP API or scrape HTML manually with `axios + cheerio`.
* Use an official API (DDG has a minimal Instant Answer API, but it’s limited).

Here we’ll illustrate using the **`duckduckgo-search`** package (which is a JS port of the Python library). This handles pagination and scraping internally. We will retrieve text results.

**TypeScript Code Example (duckduckgo\_osint.ts):**

```ts
import { FastMCP } from "fastmcp";
import * as duckDuckGoSearch from "duckduckgo-search";  // uses CommonJS require under the hood

const server = new FastMCP({ name: "duckduckgo", version: "1.0.0" });

server.addTool({
  name: "search_duckduckgo_text",
  description: "Search DuckDuckGo for a query (text results)",
  parameters: {
    query: "string",
    max_results: "number?",
    region: "string?",
    safesearch: "string?",   // "off", "moderate", or "on"
    timelimit: "string?"     // e.g. "d","w","m","y" for day, week, month, year
  },
  execute: async (args) => {
    const { query, max_results = 20, region = "wt-wt", safesearch = "moderate", timelimit = null, delay = 2.0 } = args;
    // Rate limiting: ensure at least `delay` seconds between calls
    // (Reuse a mechanism like the rateLimit() from link_follower if needed)
    // ... (implement delay if needed)
    try {
      const results = [];
      let count = 0;
      // duckduckgo-search.text returns an async iterator over result objects
      for await (const res of duckDuckGoSearch.text(query, { 
                      region, safesearch, time: timelimit })) {
        // Each `res` has { title, body, href, ... } similar to Python
        results.push({
          title: res.title || "",
          href: res.href || "",
          snippet: res.body ? stripHtml(res.body) : ""    // stripHtml to clean snippet
        });
        if (++count >= max_results) break;
      }
      // Prepare markdown snippets list
      const resultsMarkdown = results.map((r, i) => {
        const title = r.title || "(no title)";
        const snippet = r.snippet || "";
        return `${i+1}. [${title}](${r.href}) — ${snippet}`;
      });
      return {
        status: "success",
        backend: "html",       // as in Python, indicating method used
        query,
        results,
        results_markdown: resultsMarkdown
      };
    } catch (e: any) {
      return { status: "error", query, message: e.message || String(e) };
    }
  }
});

function stripHtml(html: string): string {
  // Simple helper to strip HTML tags from a snippet string
  return html.replace(/<[^>]+>/g, "").trim();
}

server.start({ transportType: "stdio" });
```

**Explanation:**

* We call `duckDuckGoSearch.text(query, options)` to get results. This returns an **async iterator**. We loop with `for await ... of` to accumulate results up to `max_results`.
* We provide options for region, safesearch, timelimit to mimic the Python tool’s parameters. (Ensure the library supports these options; some libraries might use slightly different option keys, check their docs.)
* Each result’s HTML snippet (body) is cleaned via a simple regex (`stripHtml`). Alternatively, we could use `cheerio.load(snippet).text()`, but regex suffices for small snippet strings.
* Finally, format a markdown list of results (`results_markdown`) just like the Python version (each entry `"N. [Title](URL) — snippet"`).
* If the library throws an exception (e.g., network error or DDG block), catch and return an error status.

This yields a JSON output with fields: status, backend (we label it “html” to indicate HTML-scraping backend used), the query, an array of results, and a parallel array of markdown strings.

*Alternative:* If not using an external library, you could perform a GET request to `https://html.duckduckgo.com/html/?q=<query>` (DDG’s HTML results page) with appropriate parameters (region, safesearch, etc.), then parse the HTML with cheerio to extract results. This is more involved, so leveraging a library like above (or `duck-duck-scrape`) saves time.

### 3. Email OSINT Tool (Mosint, Holehe, H8mail)

**Purpose:** Given an email address, gather OSINT data from multiple tools:

* **Holehe** – checks which services have an account with that email.
* **Mosint** – gathers email intelligence (breach data, social media, etc.).
* **H8mail** – finds breaches and pastes containing the email.

The Python implementation called each tool’s CLI and aggregated results. We’ll do the same in Node using `child_process`. Each sub-tool can be its own MCP tool, and we can have a combined `search_email_all` that runs all available ones.

**Key tasks:**

* Check if each CLI tool is installed (accessible in PATH).
* Validate email format.
* Run each CLI via `child_process.spawnSync` or `exec` and capture output.
* Parse outputs (which might be text or JSON files) to produce structured results.
* Merge results and summarize.

**Executing CLI commands in Node:** We use Node’s `child_process`. For simplicity, `spawnSync` is a good choice for these command-line tools (they run and complete, returning output). We’ll ensure to set a timeout and capture stdout/stderr.

**TypeScript Code Example (email\_osint.ts):**

```ts
import { FastMCP } from "fastmcp";
import { spawnSync } from "child_process";
import * as fs from "fs";
import * as os from "os";

const server = new FastMCP({ name: "email", version: "1.0.0" });

// Utility: Validate basic email pattern
const EMAIL_REGEX = /[^@]+@[^@]+\.[^@]+/;
function isValidEmail(email: string): boolean {
  return EMAIL_REGEX.test(email);
}

// Utility: Check if a CLI tool exists (by trying `which` command)
function toolAvailable(cmd: string): boolean {
  const res = spawnSync("which", [cmd]);
  return res.status === 0;
}

// OSINT sub-tool 1: Holehe
server.addTool({
  name: "search_email_holehe",
  description: "Check online services for an email (Holehe)",
  parameters: { email: "string", timeout: "number?" },
  execute: async ({ email, timeout = 60 }) => {
    if (!toolAvailable("holehe")) {
      return { status: "error", message: "holehe not installed — run `pip install holehe`" };
    }
    if (!isValidEmail(email)) {
      return { status: "error", message: "Invalid email address" };
    }
    const proc = spawnSync("holehe", [email], { encoding: "utf-8", timeout: timeout*1000 });
    if (proc.status !== 0) {
      return { status: "error", message: `holehe failed: ${proc.stderr}` };
    }
    // Parse Holehe output lines like "[+]/[-] [Service] : [Status]"
    const stdout = proc.stdout || "";
    const lines = stdout.split("\n").map(l => l.trim()).filter(l => l);
    const results: { service: string; found: boolean; status: string }[] = [];
    let foundCount = 0;
    // Holehe output format: e.g. "[+] Twitter : FOUND" or "[-] Facebook : Not Found"
    for (const line of lines) {
      const m = line.match(/^\[(\+|\-)\]\s*(.+?)\s*:\s*(.*)$/);
      if (!m) continue;
      const [ , sign, service, result] = m;
      const found = (sign === "+") || /found/i.test(result);
      results.push({
        service: service.trim(),
        found,
        status: found ? "Account found" : "Not found"
      });
      if (found) foundCount++;
    }
    return {
      status: "success",
      email,
      tool: "holehe",
      results,
      total_found: foundCount,
      total_checked: results.length
    };
  }
});

// OSINT sub-tool 2: Mosint
server.addTool({
  name: "search_email_mosint",
  description: "Gather email intel using Mosint",
  parameters: { email: "string", timeout: "number?" },
  execute: async ({ email, timeout = 120 }) => {
    if (!toolAvailable("mosint")) {
      return { status: "error", message: "mosint not installed — see github.com/alpkeskin/mosint" };
    }
    if (!isValidEmail(email)) {
      return { status: "error", message: "Invalid email address" };
    }
    // Mosint outputs JSON to a file; prepare a temp file path
    const tmpFile = `${os.tmpdir()}/mosint_${email.replace(/@/g, "_at_")}.json`;
    // Try new CLI syntax first: `mosint <email> -o <file>`
    let proc = spawnSync("mosint", [email, "-o", tmpFile], { encoding: "utf-8", timeout: timeout*1000 });
    // If it failed with unrecognized flag, try legacy syntax: `mosint -e <email> -json <file>`
    if (proc.status !== 0 && /unknown (flag|shorthand)/i.test(proc.stderr)) {
      proc = spawnSync("mosint", ["-e", email, "-json", tmpFile], { encoding: "utf-8", timeout: timeout*1000 });
    }
    if (proc.status !== 0 && !fs.existsSync(tmpFile)) {
      return { status: "error", message: `mosint failed: ${proc.stderr.substring(0,800)}` };
    }
    let data: any = null;
    if (fs.existsSync(tmpFile)) {
      try {
        const fileContent = fs.readFileSync(tmpFile, "utf-8");
        data = JSON.parse(fileContent);
      } catch (e) {
        // If JSON parse fails, handle below
      } finally {
        fs.unlinkSync(tmpFile);  // remove temp file
      }
    }
    if (data && typeof data === "object") {
      const breachCount = Array.isArray(data.breaches) ? data.breaches.length : 0;
      const socialCount = Array.isArray(data.social_media) ? data.social_media.length : 0;
      return {
        status: "success",
        email,
        tool: "mosint",
        data,
        breach_count: breachCount,
        social_media_count: socialCount
      };
    } else {
      // No JSON output (older mosint with no JSON result)
      return {
        status: "partial_success",
        email,
        tool: "mosint",
        raw_output: proc.stdout?.substring(0,10000) || "",
        message: "mosint ran but produced no JSON"
      };
    }
  }
});

// OSINT sub-tool 3: H8mail
server.addTool({
  name: "search_email_h8mail",
  description: "Find breaches using H8mail",
  parameters: { email: "string", timeout: "number?" },
  execute: async ({ email, timeout = 60 }) => {
    if (!toolAvailable("h8mail")) {
      return { status: "error", message: "h8mail not installed — run `pip install h8mail`" };
    }
    if (!isValidEmail(email)) {
      return { status: "error", message: "Invalid email address" };
    }
    const tmpFile = `${os.tmpdir()}/h8mail_${email.replace(/@/g, "_at_")}.json`;
    const proc = spawnSync("h8mail", ["-t", email, "-j", tmpFile], { encoding: "utf-8", timeout: timeout*1000 });
    if (fs.existsSync(tmpFile) && fs.statSync(tmpFile).size > 0) {
      let data: any;
      try {
        data = JSON.parse(fs.readFileSync(tmpFile, "utf-8"));
      } finally {
        fs.unlinkSync(tmpFile);
      }
      // H8mail JSON is an array; breaches may be nested in data[0].data
      const breaches: { source: string; breach_data: string }[] = [];
      if (Array.isArray(data) && data[0]?.data) {
        for (const entry of data[0].data) {
          breaches.push({
            source: entry.source || "Unknown",
            breach_data: entry.breach || ""
          });
        }
      }
      return {
        status: "success",
        email,
        tool: "h8mail",
        breaches,
        breach_count: breaches.length,
        full_data: data
      };
    }
    if (proc.status !== 0) {
      return { status: "error", message: `h8mail failed: ${proc.stderr}` };
    }
    // If no JSON file but no error, parse stdout for summary as fallback
    const m = proc.stdout.match(/Found (\d+) results for/i);
    return {
      status: "partial_success",
      email,
      tool: "h8mail",
      breach_count: m ? parseInt(m[1], 10) : 0,
      raw_output: proc.stdout.substring(0,5000)
    };
  }
});

// Aggregate tool: run all available email OSINT tools
server.addTool({
  name: "search_email_all",
  description: "Run all available email OSINT tools (holehe, mosint, h8mail)",
  parameters: { email: "string", timeout: "number?" },
  execute: async ({ email, timeout = 180 }) => {
    if (!isValidEmail(email)) {
      return { status: "error", message: "Invalid email address" };
    }
    const toolsInstalled = {
      holehe: toolAvailable("holehe"),
      mosint: toolAvailable("mosint"),
      h8mail: toolAvailable("h8mail")
    };
    if (!toolsInstalled.holehe && !toolsInstalled.mosint && !toolsInstalled.h8mail) {
      return { status: "error", message: "No email OSINT tools installed (mosint, holehe, h8mail)" };
    }
    const activeTools = Object.entries(toolsInstalled).filter(([, ok]) => ok);
    // Divide timeout among tools (at least 30s each)
    const perToolTimeout = Math.max(30, Math.floor((timeout || 180) / activeTools.length));
    const result: any = { email, tools_run: [] };
    // Run each tool sequentially (to avoid overloading system)
    if (toolsInstalled.holehe) {
      result.holehe = await server.callTool("search_email_holehe", { email, timeout: perToolTimeout });
      result.tools_run.push("holehe");
    }
    if (toolsInstalled.mosint) {
      result.mosint = await server.callTool("search_email_mosint", { email, timeout: perToolTimeout });
      result.tools_run.push("mosint");
    }
    if (toolsInstalled.h8mail) {
      result.h8mail = await server.callTool("search_email_h8mail", { email, timeout: perToolTimeout });
      result.tools_run.push("h8mail");
    }
    // Determine overall status: success if any success, partial_success if any partial (and none success), else error
    let overallStatus: string = "error";
    if (result.tools_run.some(t => result[t]?.status === "success")) {
      overallStatus = "success";
    } else if (result.tools_run.some(t => result[t]?.status === "partial_success")) {
      overallStatus = "partial_success";
    } else {
      overallStatus = "error";
      result.message = "All tools failed";
    }
    result.status = overallStatus;
    // Summary counts
    const summary = { accounts_found: 0, breaches_found: 0, services_checked: 0 };
    if (result.holehe) {
      summary.accounts_found += (result.holehe.total_found || 0);
      summary.services_checked += (result.holehe.total_checked || 0);
    }
    if (result.mosint) {
      summary.accounts_found += (result.mosint.social_media_count || 0);
      summary.breaches_found += (result.mosint.breach_count || 0);
    }
    if (result.h8mail) {
      summary.breaches_found += (result.h8mail.breach_count || 0);
    }
    result.summary = summary;
    return result;
  }
});

server.start({ transportType: "stdio" });
```

**Explanation:**

* We define separate tools for each sub-command (`search_email_holehe`, `search_email_mosint`, `search_email_h8mail`) and one aggregator `search_email_all`.
* The `toolAvailable()` function uses a shell `which` to check if the command exists. If you prefer not to rely on shell, you could attempt to spawn the tool with a `--help` flag and see if it executes, but `which` is quick and straightforward on Linux/Unix. (On Windows, one might check `where.exe` or just attempt spawn and catch ENOENT error.)
* Each sub-tool function:

  * Validates the email format.
  * Runs the CLI using `spawnSync`. We use `encoding: 'utf-8'` so that `stdout` and `stderr` come back as strings (not Buffers). We also set a `timeout` in milliseconds to avoid hanging.
  * Checks `proc.status` (exit code). If non-zero, returns an error with stderr output.
  * Otherwise, parses the output:

    * **Holehe:** Plain text output; we use regex to parse lines. We count how many “Account found” entries.
    * **Mosint:** Outputs JSON to a file. We run the command with appropriate flags to generate JSON (`-o file` or the legacy `-json file`). Then read the JSON file and parse it. We remove the temp file after reading. We return the parsed data and include counts of breaches and social\_media items. If no JSON was produced but the tool ran, we return a `partial_success` with raw stdout.
    * **H8mail:** Similar approach: outputs JSON if `-j` flag is used. We parse the JSON file if present and extract a simplified list of breaches (source and breach info). If the file isn’t produced but the process didn’t error, we check stdout for a summary line (H8mail prints “Found X results for ...”) and return that as a partial result.
* In `search_email_all`, we:

  * Check at least one tool is installed, else return error.
  * Allocate a portion of the total timeout to each tool (to avoid exceeding the overall user-specified timeout). We ensure a minimum of 30 seconds each (since some tools need time or the user might set a very low total).
  * Call each installed sub-tool in turn (using `server.callTool` – an internal call to our own tool definitions). We collect their outputs in an object.
  * Determine an overall status: we prefer “success” if any tool succeeded, else “partial\_success” if any partial (and none full success), otherwise “error” if all failed. We also add an error message if all failed.
  * Compute a summary: count total accounts found (Holehe’s `total_found` + Mosint’s `social_media_count`), total breaches found (Mosint’s `breach_count` + H8mail’s `breach_count`), and services checked (Holehe’s `total_checked`). This summary mimics the Python’s `summary` field.
* Each sub-tool’s output structure is designed to match the Python version, making it easier to verify correctness.

**Special Notes:**

* Calling external tools from Node is generally straightforward, but note that **output sizes** can be large. If you expect extremely large output (e.g., thousands of lines), the default `spawnSync` buffer might be sufficient, but `exec` (which buffers everything) has a default `maxBuffer` of \~1MB. We used `spawnSync` which doesn’t have a fixed cap besides memory. For very large outputs, an asynchronous streaming approach with `spawn` might be needed. In our case, the outputs are moderate (and we trim them in partial success cases).
* We must ensure to clean up any temporary files. The code above uses `fs.unlinkSync` to remove JSON files created by Mosint/H8mail.
* We assume these CLI tools are installed and in the PATH. MCPO typically runs locally, so it inherits your environment PATH. If needed, you can specify full paths or allow configuration of the command names.

### 4. Username OSINT Tool (Sherlock)

**Purpose:** Check for the existence of a username on many platforms using [Sherlock](https://github.com/sherlock-project/sherlock). Sherlock is a Python tool; here we treat it as a CLI command. Given a username, Sherlock will print lines indicating which sites have the username taken.

**Approach:**

* Ensure Sherlock is installed. (It can be installed via pip, and provides a CLI command `sherlock`. Alternatively, one can run it via `python -m sherlock ...` if installed as a module. For simplicity, we’ll assume the `sherlock` command is available.)
* Run `sherlock <username>` with appropriate flags for timeout, NSFW, etc.
* Parse the output lines to separate “found” vs “not found” sites.
* Optionally, provide a tool to check installation/version.

**TypeScript Code Example (username\_osint.ts):**

```ts
import { FastMCP } from "fastmcp";
import { spawnSync } from "child_process";

const server = new FastMCP({ name: "username", version: "1.0.0" });

// Utility: Check if sherlock is installed
function sherlockAvailable(): boolean {
  const res = spawnSync("which", ["sherlock"]);
  if (res.status === 0) return true;
  // As fallback, check if running "python -c 'import sherlock'" works
  const pyCheck = spawnSync("python", ["-c", "import sherlock"], { stdio: "ignore" });
  return pyCheck.status === 0;
}

// Tool: search for username
server.addTool({
  name: "search_username",
  description: "Search for a username on various platforms via Sherlock",
  parameters: {
    username: "string",
    timeout: "number?",
    print_all: "boolean?",
    only_found: "boolean?",
    nsfw: "boolean?"
  },
  execute: async ({ username, timeout = 120, print_all = false, only_found = true, nsfw = false }) => {
    if (!sherlockAvailable()) {
      return { status: "error", message: "Sherlock is not installed. Please install it (pip install sherlock-project)." };
    }
    if (!username || typeof username !== "string") {
      return { status: "error", message: "Invalid username provided" };
    }
    // Build command arguments
    const args = [username];
    if (timeout && timeout > 0) {
      args.push("--timeout", String(timeout));
    }
    if (print_all) args.push("--print-all");
    if (nsfw) args.push("--nsfw");
    const proc = spawnSync("sherlock", args, { encoding: "utf-8", timeout: (timeout + 10) * 1000 });
    if (proc.status !== 0) {
      return { status: "error", message: `Sherlock search failed: ${proc.stderr}` };
    }
    const outputLines = proc.stdout.trim().split("\n");
    const results: { site: string; url: string; status: string; error?: string }[] = [];
    // Sherlock output lines are like:
    // "[*] Checking username on:" (header line)
    // "[+] SiteName: URL" for found
    // "[-] SiteName: Not Found" for not found (if --print-all)
    for (const line of outputLines.slice(1)) {  // skip first line
      const text = line.trim();
      if (!text) continue;
      const parts = text.split(": ", 2);
      if (parts.length < 2) continue;
      const statusSite = parts[0];  // e.g. "[+]{space}SiteName" or "[-] SiteName"
      const urlOrMsg = parts[1];    // URL if found, or message if not found
      const siteName = statusSite.replace(/^\[\+|\[\-\]\s*/, "").trim();
      const found = statusSite.startsWith("[+]");
      if (only_found && !found) {
        continue;  // skip "not found" if only_found is true
      }
      results.push({
        site: siteName,
        url: found ? urlOrMsg.trim() : "",
        status: found ? "claimed" : "not found"
      });
    }
    return {
      status: "success",
      username,
      results,
      total_found: results.filter(r => r.status === "claimed").length,
      total_sites_checked: only_found ? undefined : results.length
    };
  }
});

// Optional: tool to check Sherlock installation and version
server.addTool({
  name: "check_sherlock_installation",
  description: "Verify if Sherlock is installed and retrieve version",
  execute: async () => {
    if (!sherlockAvailable()) {
      return { status: "not_installed", message: "Sherlock is not installed. Please install it." };
    }
    try {
      const verProc = spawnSync("sherlock", ["--version"], { encoding: "utf-8" });
      if (verProc.status === 0) {
        return { status: "installed", version: verProc.stdout.trim() };
      } else {
        return { status: "installed", message: "Sherlock is installed but version info not available" };
      }
    } catch (e: any) {
      return { status: "error", message: `Error checking Sherlock installation: ${e.message}` };
    }
  }
});

server.start({ transportType: "stdio" });
```

**Explanation:**

* `sherlockAvailable()` checks for the `sherlock` command (using `which`). If not found, it attempts to see if the Python module is present by spawning `python -c "import sherlock"`. This mimics the Python tool’s approach.
* In `search_username.execute`:

  * We assemble the command arguments based on optional flags. (Note: `nsfw: true` means include NSFW sites, which in Sherlock is enabled by `--nsfw` flag, consistent with the Python default usage.)
  * We run Sherlock with an adjusted timeout: `timeout + 10` seconds (Sherlock may internally have per-request timeouts; giving a slight buffer).
  * Parse the output lines: skip the first line (it's just a banner like “\[\*] Checking username...”). Then for each subsequent line, determine if it indicates a found account or not by the prefix `[+]` vs `[-]`. We only include results in the final list if the account was found **or** if `only_found` is false (meaning the user wants all checked sites listed).
  * Construct the results array with `site`, `url`, and status (`"claimed"` for found, `"not found"` for not found). We drop any lines that don’t match the expected format or are empty.
  * Calculate `total_found` and `total_sites_checked` similar to Python: if we returned only found accounts, `total_sites_checked` can be omitted or set to the number of sites that had accounts (or left undefined); if we included all, `total_sites_checked` is the number of entries in results.
* We also added a `check_sherlock_installation` tool that returns either `status: "installed"` (with version if possible) or not\_installed. This can help in debugging deployment issues (and mirrors the Python code’s approach for a check tool).

### 5. Phone OSINT Tool (PhoneInfoga)

**Purpose:** Scan a phone number using [PhoneInfoga](https://github.com/sundowndev/PhoneInfoga) and optionally follow any URLs found in the output for mentions of that number. The Python tool wraps the PhoneInfoga CLI (`phoneinfoga-bin`) and does a concurrent web search on found links.

**Approach:**

* Ensure `phoneinfoga` CLI is installed (the user’s Python used an Arch package `phoneinfoga-bin`).
* Validate phone number format (basic regex).
* Run `phoneinfoga scan -n <number>` via child\_process.
* Extract URLs from the output (using regex).
* If not in “no\_follow” mode, fetch those URLs in parallel and find which pages contain the phone number.
* Return a summary and details (list of all URLs, list of “hit” URLs where the number appears, markdown link list of hits, raw output, etc.).

**Challenges:**

* Concurrent HTTP requests in Node: we can use axios or native `https` for this. Using `Promise.all` to fetch \~40 links concurrently is usually fine. We should use a reasonable `timeout` and a user-agent.
* Parsing HTML for a phone number mention: simplest is to do a case-insensitive search on the page text for the number (normalized) rather than full parsing, which is what the Python did by loading into BeautifulSoup.

**TypeScript Code Example (phone\_osint.ts):**

```ts
import { FastMCP } from "fastmcp";
import { spawnSync } from "child_process";
import axios from "axios";

const server = new FastMCP({ name: "phone", version: "1.0.0" });

const PHONE_REGEX = /^\+?\d[\d\s\-.]{5,20}$/;  // simplistic phone number pattern
const UA = "Mozilla/5.0 (compatible; OSINT-PhoneScanner/1.0)";
const HTTP_TIMEOUT = 10000;  // 10 seconds per request
const MAX_LINKS = 40;
const MAX_CONCURRENT = 12;   // concurrency limit for link fetching (if needed)

// Utility: Check CLI availability
function phoneinfogaAvailable(): boolean {
  return spawnSync("which", ["phoneinfoga"]).status === 0 || spawnSync("which", ["phoneinfoga-bin"]).status === 0;
}

// Helper: Fetch a URL and check if it contains the needle (normalized number)
async function fetchAndSearch(url: string, needle: string): Promise<{ url: string; title: string } | null> {
  try {
    const res = await axios.get(url, { headers: { "User-Agent": UA }, timeout: HTTP_TIMEOUT });
    if (res.status !== 200 || typeof res.data !== "string") {
      return null;
    }
    const pageText = res.data.toLowerCase();
    if (pageText.includes(needle)) {
      // Extract title tag content if present
      const titleMatch = res.data.match(/<title>([^<]{0,150})<\/title>/i);
      let title = "";
      if (titleMatch) {
        title = titleMatch[1].trim();
        if (!title) title = "(untitled)";
      } else {
        title = "(untitled)";
      }
      return { url, title };
    }
  } catch {
    // Ignore request errors
  }
  return null;
}

// Tool: Check installation
server.addTool({
  name: "check_tools_installation",
  description: "Check if PhoneInfoga CLI is installed",
  execute: async () => {
    return phoneinfogaAvailable()
      ? { status: "ok", cli: "phoneinfoga" }
      : { status: "missing_tools", message: "phoneinfoga CLI not found. Please install PhoneInfoga." };
  }
});

// Tool: Scan phone number using PhoneInfoga
server.addTool({
  name: "scan_phone_phoneinfoga",
  description: "Scan a phone number with PhoneInfoga",
  parameters: { number: "string", timeout: "number?", no_follow: "boolean?" },
  execute: async ({ number, timeout = 60, no_follow = false }) => {
    if (!phoneinfogaAvailable()) {
      return { status: "missing_tools", message: "phoneinfoga not installed." };
    }
    number = number.trim();
    if (!PHONE_REGEX.test(number)) {
      return { status: "error", message: "Invalid phone number" };
    }
    // Run PhoneInfoga CLI
    let proc;
    try {
      proc = spawnSync("phoneinfoga", ["scan", "-n", number], { encoding: "utf-8", timeout: timeout * 1000 });
    } catch (e: any) {
      if (e.status === undefined && e.signal) {
        return { status: "error", message: `PhoneInfoga timed out after ${timeout}s` };
      }
      return { status: "error", message: `Execution failed: ${e.message}` };
    }
    if (proc.status !== 0) {
      return { status: "error", message: `PhoneInfoga exit code ${proc.status}: ${proc.stderr.substring(0,800)}` };
    }
    const stdout = proc.stdout || "";
    // Find all URLs in output (using regex similar to Python's)
    const urlRegex = /https?:\/\/[^\s)'"<>]+/g;
    let urlsAll = stdout.match(urlRegex) || [];
    // Deduplicate URLs
    urlsAll = Array.from(new Set(urlsAll));
    // If no_follow or no URLs, we skip link following
    let hitsInfo: { url: string; title: string }[] = [];
    if (!no_follow && urlsAll.length > 0) {
      const needle = number.replace(/[ \-.]/g, "").toLowerCase();
      const urlsToFetch = urlsAll.slice(0, MAX_LINKS);
      // Fetch concurrently (limit concurrency if needed)
      const fetchPromises = urlsToFetch.map(url => fetchAndSearch(url, needle));
      // If limiting concurrency, you could chunk the promises or use p-limit. For simplicity:
      const results = await Promise.all(fetchPromises);
      hitsInfo = results.filter((r): r is { url: string; title: string } => r !== null);
    }
    // Prepare markdown list of hits
    const hitsMarkdown = hitsInfo.map((hit, idx) => `${idx+1}. [${hit.title}](${hit.url})`);
    return {
      status: "success",
      number,
      tool: "PhoneInfoga",
      summary: {
        total_links: urlsAll.length,
        links_with_hits: hitsInfo.length
      },
      links_all: urlsAll,
      links_hits: hitsInfo,
      links_hits_markdown: hitsMarkdown,
      raw_output: stdout
    };
  }
});

// Optional: Combine with future tools (if any)
// For now, we can have an alias that just calls PhoneInfoga scan (since that's the primary tool):
server.addTool({
  name: "scan_phone_all",
  description: "Scan phone number with all available tools (currently PhoneInfoga only)",
  parameters: { number: "string", timeout: "number?", no_follow: "boolean?" },
  execute: async (args) => {
    const res: any = await server.callTool("scan_phone_phoneinfoga", args);
    return {
      status: res.status,
      number: args.number,
      tools_run: ["PhoneInfoga"],
      phoneinfoga: res,
      summary: res.status === "success" ? res.summary : undefined
    };
  }
});

server.start({ transportType: "stdio" });
```

**Explanation:**

* `phoneinfogaAvailable()` checks for the presence of the `phoneinfoga` command (or the Arch-specific `phoneinfoga-bin`). Adjust this if your system uses a different command name.
* `fetchAndSearch(url, needle)`: uses axios to GET the URL and looks for the `needle` (the normalized phone number) in the page text. If found, it extracts the `<title>` for context. We limit to a 10s timeout per request to avoid hanging. This is used to follow links concurrently.
* `scan_phone_phoneinfoga.execute`:

  * Validates installation and input format.
  * Runs the CLI (`phoneinfoga scan -n number`). We capture stdout/stderr with a timeout. If `spawnSync` throws due to timeout, we handle it.
  * Extracts URLs using a regex. We then deduplicate them with a `Set`.
  * If `no_follow` is false and we have URLs, we normalize the phone number (remove spaces, dashes, dots, to lower-case) and then fetch each URL via `fetchAndSearch`. We use `Promise.all` to fetch concurrently. (We could incorporate a concurrency limit if `urlsAll` is large; using 40 links and up to 12 concurrent as the Python suggests is fine. Node can handle 40 concurrent HTTP requests, but if needed, one could use a library like `p-limit` or manually batch the promises to respect `MAX_CONCURRENT`.)
  * Collect the results where the number was mentioned (`hitsInfo`).
  * Prepare `links_hits_markdown` as an array of markdown strings listing the hits with titles.
  * Return an object with `status`, the input `number`, `tool` name, a `summary` of total links vs hits, full list of URLs, list of hits (each with url and title), the markdown list, and the `raw_output` from PhoneInfoga.
* The `scan_phone_all` tool in this case doesn’t add much (we only have PhoneInfoga as the implemented phone scanner). It calls `scan_phone_phoneinfoga` and wraps the result in an object that could later combine multiple tools. We include `tools_run: ["PhoneInfoga"]` and nest the Phoneinfoga result. If in the future there were multiple phone scanning tools, they could be integrated similarly by adding their outputs to this aggregate.

**Note:** We chose to implement concurrency using `Promise.all` for simplicity. Node’s default concurrency (DNS lookup, etc.) should handle a dozen simultaneous requests. If you encounter performance issues or want to be more polite, you can limit concurrency. For example, using `for` loops with `await` to process a few at a time, or using a concurrency control library, but this may not be necessary for \~40 URLs.

## Building and Serving the Tools with MCPO

After implementing the tools, you need to **compile and register them with MCPO** so Open WebUI (or any OpenAPI client) can use them.

**Build the TypeScript**: Run `npm run build` (using the script set up earlier) to transpile all `.ts` files to `.js` in the `dist/` directory. You should end up with files like `dist/OSINT/link_follower_osint.js`, etc.

**MCPO Configuration**: MCPO uses a config (by default `config.json`) to know what commands to run for each tool server. Replace the Python tool entries with the Node commands. For example, your `config.json` might have:

```json
{
  "mcpServers": {
    "email":    { "command": "node", "args": ["dist/OSINT/email_osint.js"] },
    "username": { "command": "node", "args": ["dist/OSINT/username_osint.js"] },
    "phone":    { "command": "node", "args": ["dist/OSINT/phone_osint.js"] },
    "duckduckgo": { "command": "node", "args": ["dist/OSINT/duckduckgo_osint.js"] },
    "link_follower": { "command": "node", "args": ["dist/OSINT/link_follower_osint.js"] }
  }
}
```

Each entry under `mcpServers` names the tool (this becomes the base path in the OpenAPI URL) and specifies how to start the server. We use the Node executable and point it at the compiled JS file. This mirrors how the Python tools were configured, except using `node` instead of Python. For instance, the `link_follower` in the user’s config was switched to Node and pointed at the TS build.

With this config, launching `mcpo` will spawn each Node process and connect to it via stdio. MCPO will expose an OpenAPI endpoint for each tool, with routes corresponding to each `server.addTool` we defined. For example, `username/search_username` will be one operation, `email/search_email_holehe` another, etc., all under the base path of each server.

**Verifying Deployment**: You can navigate to Open WebUI’s tool interface or the auto-generated Swagger UI for these endpoints to ensure they are recognized. Each tool’s functions (tools) should appear as operations with their parameters defined (since FastMCP and MCPO work together to produce OpenAPI docs automatically).

## WebSockets vs OpenAPI in Open WebUI

Open WebUI primarily interacts with tools via **OpenAPI (REST HTTP)** using the MCPO proxy. This means your MCP tools (running over stdio) are exposed as HTTP endpoints for the UI or other clients. However, Open WebUI **also supports streaming via SSE or WebSockets** for tools that need it.

* **Default (OpenAPI)**: MCPO wraps your stdio MCP servers into HTTP endpoints. Each tool call is a separate HTTP request/response. This is straightforward and works well for most cases.

* **Server-Sent Events (SSE)**: If your tool needs to stream partial results or progress (for example, streaming search results as they come), FastMCP servers can be run with SSE transport or “streamable HTTP”. In fact, FastMCP supports multiple transport protocols – stdio (default), HTTP streaming, SSE. Open WebUI’s MCPO and related utilities (like the `supergateway`) can bridge an stdio server to SSE or WebSocket. This means you could run your tool with `transportType: "sse"` in FastMCP to listen on a local port, and then configure Open WebUI to connect via SSE or WS.

* **WebSockets**: WebSocket support for MCP is emerging via bridging tools. Open WebUI 0.6+ emphasizes OpenAPI, but it provides an MCP bridge. There’s a concept of running an MCP server over WebSocket for remote use. For example, the **Harbor SuperGateway** can wrap a stdio MCP server and expose it over SSE or WebSocket. In practice, if you are using MCPO, you likely won’t directly use WebSockets for your own tool code – MCPO handles the HTTP layer. But if you wanted to bypass MCPO and connect a client directly to your MCP server, FastMCP could start a WebSocket server (the Python FastMCP mentions a WebSocket transport in proposals, but current TS FastMCP offers SSE/HTTP as shown above).

**Implications for Tool Development:** For most developers, you don’t need to implement WebSocket handling in your tool – use the default stdio and let MCPO handle communication. If you want streaming, consider using SSE (`transportType: "sse"`) or ensure your tool can send partial outputs. FastMCP makes this possible via context events, but that’s advanced usage. The bottom line: **Open WebUI will consume your tools over OpenAPI by default**, so focus on correct request/response handling. WebSocket support is mainly relevant if you plan on long-lived connections or pushing data without polling, but that typically requires a specialized client or UI support.

In summary, Open WebUI’s MCP integration is flexible – it can use OpenAPI/HTTP calls (simplest), or use SSE/WebSocket bridging for streaming. We’ve set our servers to stdio which is perfect for MCPO. Should requirements change, you can start your FastMCP server with `server.start({ transportType: "sse", sse: { port: 8080, endpoint: "/sse" } })` to serve SSE on a port, and then configure Open WebUI (or another client) to connect to that SSE endpoint directly. This is an advanced deployment scenario and not necessary for basic usage.

## TypeScript Tips: Typings and Subprocess Handling

In porting these tools to TypeScript, you might encounter some common hurdles. Here are some **cheat-sheet** tips:

* **Dynamic JSON Response Types:** Our tool functions often return rich JSON objects with varying structure. Writing precise TypeScript types for every field can be complex. You have a few options:

  * Define interfaces for consistent parts of the output and use index signatures or optional properties for the rest. For example:

    ```ts
    interface BasicResult {
      status: string;
      message?: string;
      [key: string]: any;  // allow additional dynamic fields
    }
    interface EmailToolResult extends BasicResult {
      email?: string;
      tool?: string;
      results?: Array<Record<string, any>>;
      total_found?: number;
      // ... etc.
    }
    ```

    This way, you document expected keys but allow flexibility. The downside is less strict checking.
  * Use union types for distinct outcomes (success vs error). E.g.:

    ```ts
    type SherlockResult = 
      | { status: "success"; username: string; results: SiteResult[]; total_found: number; total_sites_checked?: number }
      | { status: "error"; message: string };
    ```

    This is more rigorous. It ensures you handle each case, but can be verbose to define for every tool.
  * **Casting and `any`:** When dealing with parsed JSON from external tools (like `JSON.parse` on Mosint output), the result is type `any`. You can cast to a defined type if you have one, e.g. `const data = JSON.parse(text) as MosintData`. If you don’t have a full schema, you might leave it as `any` and carefully access fields with runtime checks (as we did with `if (Array.isArray(data.breaches))` etc.). It’s acceptable to use `any` in these glue-code scenarios to keep things simple – just document what the structure is expected to be.
  * **Zod schemas for output:** If you want extra safety, you could define Zod schemas for the output JSON as well and validate at runtime. This can ensure the CLI outputs match expectations (helpful if those tools update and change format). This is optional and adds overhead, so use it based on your needs.

* **Using `child_process`:** In Node, there are multiple ways to run a subprocess:

  * `spawnSync(command, args, options)`: runs synchronously, returning a `SpawnSyncReturns` object with `status`, `stdout`, `stderr`. We used this for simplicity. It will block the event loop while running the subprocess, but since our tools are typically invoked one at a time per request (and expected to finish reasonably fast), this is fine.
  * `exec(command, options, callback)` or the promise-based `execSync/execFileSync`: `exec` runs the command in a shell and buffers the output (good if you want the whole output as a string). Remember to increase `maxBuffer` in options if expecting >1MB of output.
  * `spawn(command, args, options)`: runs asynchronously, returning a ChildProcess. You can stream `stdout`/`stderr` by listening to events. Use this if you want to stream output (for example, real-time feedback) or handle very large outputs incrementally. This requires more code to collect data or send partial results.

  **Common Pattern Examples:**

  * Run a command and get output (small output):

    ```ts
    import { execSync } from "child_process";
    try {
      const out = execSync(`sherlock ${username} --timeout ${timeout}`, { encoding: "utf-8", timeout: (timeout+10)*1000 });
      console.log(out);
    } catch (err) {
      // handle error (err.status, err.message, etc.)
    }
    ```
  * Spawn and gather output (async):

    ```ts
    import { spawn } from "child_process";
    const proc = spawn("phoneinfoga", ["scan", "-n", number]);
    let output = "";
    proc.stdout.on("data", chunk => output += chunk.toString());
    proc.stderr.on("data", chunk => {/* handle error output if needed */});
    proc.on("close", code => {
      if (code !== 0) { /* handle non-zero exit */ }
      else { /* process `output` string */ }
    });
    ```

    This pattern is useful if you want to start processing output before the process ends (e.g., streaming lines to the client). For our use-case, `spawnSync` and `execSync` provide simpler code since we wait for full output before parsing.

* **Timeouts:** Both `spawnSync` and `execSync` accept a `timeout` option (in milliseconds). We’ve applied this to prevent hanging. When a timeout is reached, Node throws an error (for sync methods) or emits an error event (for async). We capture that and return a meaningful JSON error (e.g., “timed out after X seconds”). Always wrap calls in try/catch if using sync methods with timeouts.

* **Ensuring CLI Path:** When MCPO runs your Node process, it inherits your environment. If a CLI like `sherlock` or `phoneinfoga` isn’t in the PATH, `toolAvailable` will fail. In such cases, you might need to update the PATH env or use absolute paths. You can modify the MCPO config to include an `"env": { "PATH": "/opt/Tools/phoneinfoga:$PATH" }` for that server if needed. Alternatively, allow configuring the CLI path via an environment variable or config file in your TS code.

* **Resource Cleanup:** After each tool execution, FastMCP will handle returning the result and resetting state for the next call. You should clean up any temp files (as we did) and avoid global variables that accumulate state (except for caches or rate-limit timestamps). If using caches (like to avoid repeated downloads), ensure thread safety (though each tool call in our scenario runs in a single Node process, sequentially per request, so concurrency issues are minimal unless you spawn your own threads or use `Promise.all`).

## Debugging and Testing MCP TypeScript Tools

Developing these tools can be tricky, but a few strategies can help:

* **Local Testing**: Before integrating with MCPO/Open WebUI, test the tool logic in isolation. You can run the Node script directly with test arguments. For example, add a simple CLI interface in your TS file for manual runs:

  ```ts
  if (require.main === module) {
    const [,, cmd, ...rest] = process.argv;
    if (cmd === "check") {
      console.log(JSON.stringify({ status: "ok", message: "Tool ready" }));
    } else if (cmd === "test_fetch") {
      const url = rest[0];
      server.callTool("fetch_url", { url }).then(res => {
        console.log(JSON.stringify(res, null, 2));
      });
    }
  }
  ```

  Then compile and run `node dist/OSINT/link_follower_osint.js test_fetch https://example.com` to see if it works. Each tool can have similar small test handlers. This is analogous to the Python scripts that allowed a `--check` or subcommands for manual use.

* **Console Logging**: Insert `console.log`/`console.error` in your code to trace execution. Be careful: when running under MCPO (stdio transport), any output to stdout that isn’t valid MCP JSON might confuse the protocol. It’s safer to use `console.error` for debug logs (MCPO usually ignores stderr unless in a verbose mode). For example, log each step to stderr: `console.error("Fetched URL, length=", html.length)`. These will show up in the terminal running MCPO, helping you trace issues without breaking the JSON response stream.

* **MCPO Logs**: MCPO typically prints when servers start, and if a tool process crashes or exits, it will log that. If your tool throws an unhandled exception, the Node process might exit – MCPO could restart it (depending on configuration) or report it as an error. Always wrap asynchronous code in try/catch or promise `.catch` to handle errors and return a JSON error instead of letting the process die. Use `process.on('unhandledRejection', ...)` or `process.on('uncaughtException', ...)` to catch anything unforeseen and log it, so you get insight rather than silent failures.

* **Swagger UI**: Once running with MCPO, navigate to the OpenAPI docs (often at `http://localhost:PORT/docs` or similar) to manually invoke the tools. This ensures the schema (parameters) look correct and the responses come through. If something is mis-typed (e.g., a parameter doesn’t show up or has wrong type), adjust the Zod schema or parameter definitions.

* **Iterative Testing**: Develop and test one tool at a time. It’s easier to confirm `duckduckgo_search` works before moving to the more complex `email_osint`. Use known inputs (e.g., a test email you own for H8mail, or a common username for Sherlock) to see how the output looks.

* **Error Handling**: Ensure that every possible error path returns a JSON with `status: "error"` (or `"missing_tools"` as we used for missing CLI). This way, the Open WebUI will receive a proper response even if something fails, instead of no response or a hung request. In our code, we tried to catch timeouts, missing tools, invalid input, and subprocess errors and turn them into structured messages.

## Cheat-Sheet: Common Patterns

For quick reference, here are some common patterns used in building these tools:

* **Subprocess Execution Patterns:**

| Use Case                                          | Method & Example                                                                                                                                                                              |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Run command, get all output (small/medium output) | `execSync` or `spawnSync` with encoding. <br>Example: `const out = spawnSync("sherlock", [username], { encoding: "utf-8", timeout: 120000 }); if (out.status === 0) console.log(out.stdout);` |
| Run command with large or streaming output        | Use `spawn` (async) and listen to `.stdout` events. <br>Example: `const cp = spawn("nmap", ["-sV", target]); cp.stdout.on('data', chunk => {...}); cp.on('close', code => {...});`            |
| Capture errors and timeouts                       | Wrap calls in try/catch (for sync) or listen for `'error'` event (for async). Check `proc.status` and `proc.stderr` for command errors. Use `timeout` option to limit runtime.                |
| Check if command exists (Unix)                    | Use `spawnSync("which", [cmd])` and check `status === 0`. Alternatively, use `fs.access` on known paths or try running `cmd --help` and see if it errors.                                     |

* **Type Handling for JSON:**

| Scenario                              | Tip                                                                                                                                                                                                                                                                                            |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Unknown JSON structure (from CLI)     | Use `any` or `unknown` and then inspect. e.g. `const data: any = JSON.parse(text); if (data?.someField) ...`                                                                                                                                                                                   |
| Dynamic keys in result object         | Use index signature in TypeScript interface: <br>`interface Result { status: string; [key: string]: any }` to allow additional properties.                                                                                                                                                     |
| Optional fields                       | Mark them optional in interface, or build result as `{ field?: Type }`. TS will allow them to be missing.                                                                                                                                                                                      |
| Combining results from multiple tools | Use union types if outputs differ greatly, or a broad type that includes all possible fields (some optional). For aggregate results, you can define sub-interfaces for each tool and make the aggregate type have those as optional properties (as we did with email OSINT combining outputs). |

* **FastMCP Usage:**

  * Registering a tool without `zod`: you can pass a simple object to `parameters` with key: type strings (as shown in some examples). FastMCP will infer basic types. Using `z.object` gives more control (ranges, etc.), but for simplicity we sometimes used an object like `{ email: "string", timeout: "number?" }` – the `?` denotes optional.
  * Starting the server: always use `server.start({ transportType: "stdio" })` when using MCPO. If you accidentally omit transport, it defaults to stdio anyway in most FastMCP versions, but being explicit is good practice.
  * You can group multiple related tools in one server (as we did, e.g., all email-related functions in one `email` server). This keeps things organized and is directly analogous to the Python version using one FastMCP instance per file.

With these patterns and examples, you should be well-equipped to implement MCP-compatible OSINT tools in TypeScript. The result will be a set of robust Node.js services that MCPO can launch and expose to Open WebUI (or any other OpenAPI-compatible interface), maintaining feature-parity with the original Python tools and benefiting from TypeScript’s maintainability and type safety.
