Perfect. I will build a detailed report focusing on OSINT command-line tools for Linux (Arch, ideally AUR-available), specifically for researching individuals (not organizations or infrastructure). I’ll break it into stages of the OSINT process like initial footprinting, email discovery, username lookup, social media scraping, and reporting. I'll include a markdown-compatible table at the beginning for easy reference, and give examples of usage for each tool.

I'll get started and will let you know once the report is ready!

# OSINT Tools for Investigating Individuals

**Open-Source Intelligence (OSINT) investigations on individuals** leverage a variety of tools to gather personal data from public sources. Below is a comprehensive overview of OSINT tools organized by investigation stage. Each tool’s name, its primary OSINT stage, installation method, and a brief description are summarized in the table. Detailed sections follow, providing overviews, example usage, and common use cases for each tool.

| **Tool Name**      | **Stage**             | **Install Method**    | **Description**                              |
|--------------------|-----------------------|-----------------------|----------------------------------------------|
| **SpiderFoot**     | Footprinting          | AUR / pip             | OSINT automation framework; finds emails, phones, etc. ([SpiderFoot – A Automate OSINT Framework in Kali Linux | GeeksforGeeks](https://www.geeksforgeeks.org/spiderfoot-a-automate-osint-framework-in-kali-linux/#:~:text=target.%20,of%20scanning%20done%20by%20Spiderfoot)) |
| **Recon-ng**       | Footprinting          | AUR / pip             | Metasploit-like recon framework; modular OSINT gathering ([Recon-NG Tutorial | HackerTarget.com](https://hackertarget.com/recon-ng-tutorial/#:~:text=Recon,gathering%20information%20from%20open%20sources)) |
| **LittleBrother**  | Footprinting          | GitHub (manual)       | Person search tool (FR/BE/CH focus); finds names, phones, etc. |
| **PhoneInfoga**    | Footprinting          | AUR / Binary          | Phone number OSINT; finds carrier, locale, social ties ([GitHub - sundowndev/phoneinfoga: Information gathering framework for phone numbers](https://github.com/sundowndev/phoneinfoga#:~:text=PhoneInfoga%20is%20one%20of%20the,help%20investigating%20on%20phone%20numbers)) ([GitHub - sundowndev/phoneinfoga: Information gathering framework for phone numbers](https://github.com/sundowndev/phoneinfoga#:~:text=,REST%20API%20and%20Go%20modules)) |
| **theHarvester**   | Email Discovery       | AUR / BlackArch / pip | Email scraper for domains; finds emails, names from public sources ([OSINT: Scraping email Addresses with TheHarvester](https://www.hackers-arise.com/post/osint-scraping-email-addresses-with-theharvester#:~:text=Summary)) |
| **Mosint**         | Email Discovery       | AUR / Go install      | All-in-one email OSINT (breaches, social, etc.) ([Open Source Intelligence (OSINT): Mosint, The Versatile Email Address Search Tool](https://www.hackers-arise.com/post/open-source-intelligence-osint-the-versatile-email-address-search-tool#:~:text=Mosint%20is%20a%20powerful%20addition,and%20more%20flexible%20reporting%20options)) |
| **Holehe**         | Email Discovery       | AUR / pip             | Checks if an email is used on 120+ sites (account existence) ([Holehe OSINT — Email to Registered Accounts | by Jayvin Gohel | Medium](https://th3m4rk5man.medium.com/holehe-osint-email-to-registered-accounts-b21bbd34d029#:~:text=Holehe%20checks%20if%20an%20email,and%20more%20than%20120%20others)) |
| **h8mail**         | Email Discovery       | pip / GitHub          | Email breach hunting tool (checks leaks via APIs or local db) ([GitHub - khast3x/h8mail: Email OSINT & Password breach hunting tool, locally or using premium services. Supports chasing down related email](https://github.com/khast3x/h8mail#:~:text=Image%3A%20Docker%20Pulls%20h8mail%20is,torrent)) |
| **Sherlock**       | Username Enumeration  | AUR / pip             | Finds profiles on 300+ sites by username ([Open-Source Intelligence(OSINT): Sherlock - The Ultimate Username Enumeration Tool](https://www.hackers-arise.com/post/open-source-intelligence-osint-sherlock-the-ultimate-username-enumeration-tool#:~:text=Sherlock%20scans%20hundreds%20of%20websites,GitHub%2C%20and%20GitLab%E2%80%94among%20many%20others)) |
| **Social Analyzer**| Username Enumeration  | pip / Docker / GitHub | Finds a person’s profiles on 1000+ sites; uses scoring to reduce false hits ([GitHub - qeeqbox/social-analyzer: API, CLI, and Web App for analyzing and finding a person's profile in 1000 social media \ websites](https://github.com/qeeqbox/social-analyzer#:~:text=Image)) |
| **Twint**          | Social Media Analysis | AUR / pip             | Twitter scraper; fetches tweets, followers, etc. without API ([GitHub - twintproject/twint: An advanced Twitter scraping & OSINT tool written in Python that doesn't use Twitter's API, allowing you to scrape a user's followers, following, Tweets and more while evading most API limitations.](https://github.com/twintproject/twint#:~:text=Twint%20is%20an%20advanced%20Twitter,profiles%20without%20using%20Twitter%27s%20API)) ([GitHub - twintproject/twint: An advanced Twitter scraping & OSINT tool written in Python that doesn't use Twitter's API, allowing you to scrape a user's followers, following, Tweets and more while evading most API limitations.](https://github.com/twintproject/twint#:~:text=Twint%20utilizes%20Twitter%27s%20search%20operators,really%20creative%20with%20it%20too)) |
| **Osintgram**      | Social Media Analysis | AUR / GitHub          | Instagram OSINT toolkit; gets followers, photos, etc. ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=Tools%20and%20Commands)) ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=,Get%20description%20of%20target%27s%20photos)) |
| **Instaloader**    | Social Media Analysis | pip                   | Instagram content downloader; saves posts, stories for analysis. |
| **GHunt**          | Social Media Analysis | GitHub (manual)       | Google account profiler; finds info from Gmail/Google IDs (YouTube, etc.). |
| **SpiderFoot**     | Reporting             | AUR / pip             | (Also Footprinting) Exports scan results (CSV, HTML) for reports. |
| **Recon-ng**       | Reporting             | AUR / pip             | (Also Footprinting) Built-in report modules (HTML, CSV export). |
| **Maltego CE**     | Reporting             | Manual (GUI app)      | Graphical link analysis for people; visualize relationships for reports. |

## Footprinting and Reconnaissance

Footprinting is the initial stage of OSINT where investigators gather as much basic information as possible about a person. This often includes names, phone numbers, emails, addresses, and social media handles. The tools in this stage automate searches across many data sources to build a profile of the target individual.

### SpiderFoot 
SpiderFoot is an open-source intelligence automation framework that can perform extensive reconnaissance through numerous modules ([SpiderFoot – A Automate OSINT Framework in Kali Linux | GeeksforGeeks](https://www.geeksforgeeks.org/spiderfoot-a-automate-osint-framework-in-kali-linux/#:~:text=is%20used%20for%20reconnaissance,methods%20for%20data%20analysis%2C%20making)) ([SpiderFoot – A Automate OSINT Framework in Kali Linux | GeeksforGeeks](https://www.geeksforgeeks.org/spiderfoot-a-automate-osint-framework-in-kali-linux/#:~:text=target.%20,of%20scanning%20done%20by%20Spiderfoot)). It integrates with many data sources and methods, enabling it to retrieve information like email addresses, social media accounts, phone numbers, and more about a target **automatically** ([SpiderFoot – A Automate OSINT Framework in Kali Linux | GeeksforGeeks](https://www.geeksforgeeks.org/spiderfoot-a-automate-osint-framework-in-kali-linux/#:~:text=target.%20,of%20scanning%20done%20by%20Spiderfoot)). SpiderFoot can run either as a web application or via command-line. It’s often used at the start of an investigation to “cast a wide net” and identify which data points are worth deeper exploration.

- **Install:** Available in Arch User Repository (AUR) as **`spiderfoot`**, or via `pip install spiderfoot`.  
- **Example Usage:** Launch the SpiderFoot web UI on localhost port 5001:  
  ```bash
  spiderfoot -l 127.0.0.1:5001
  ```  
  *This starts the SpiderFoot web interface. From there, you can input the target’s name, username, email, or phone and run modules to gather intel.* Alternatively, SpiderFoot’s CLI can run headless scans and export results (e.g., to HTML or CSV). For instance, to run a quick scan for a name or username, you could use:  
  ```bash
  spiderfoot -s "John Doe" -o sf_output.html -q
  ```  
  (Here `-s` sets the target, `-o` specifies an output file, and `-q` runs in quiet mode without the web server.)

- **Common Use:** Quickly obtaining a broad profile of an individual. Investigators often use SpiderFoot to find **associated emails, usernames, and social profiles** of a person from their full name or handle. The tool’s modular results (which can be saved to reports) help identify which specific avenues (email, social media, etc.) to pursue next. Because SpiderFoot can discover data like pastes, breaches, and even physical addresses, it serves as a one-stop initial recon tool in many cases.

### Recon-ng 
Recon-ng is a modular reconnaissance framework with an interface similar to Metasploit, tailored for web-based OSINT gathering ([Recon-NG Tutorial | HackerTarget.com](https://hackertarget.com/recon-ng-tutorial/#:~:text=Recon,gathering%20information%20from%20open%20sources)). It provides an interactive console where you can load various modules to search for data (email addresses, profiles, breaches, etc.) and then output the findings in different formats ([Recon-NG Tutorial | HackerTarget.com](https://hackertarget.com/recon-ng-tutorial/#:~:text=Recon,gathering%20information%20from%20open%20sources)). Recon-ng automates many common recon tasks through its modules and allows chaining results from one module to another (pivoting).

- **Install:** In Arch Linux, Recon-ng can be installed via BlackArch repository (`pacman -S recon-ng`) or by cloning from GitHub and installing with pip. (It may also be in the AUR as a package or one can use `pip install recon-ng`).  
- **Example Usage:** Start the interactive console by simply running:  
  ```bash
  recon-ng
  ```  
  Once in the console, you can add a workspace for your target (e.g., `workspaces add johndoe`) and load modules. For example, to search for any leaks of an email address using the HaveIBeenPwned module:  
  ```text
  [recon-ng][default] > use breaches/pwnedemail
  [recon-ng][default][pwnedemail] > set source john.doe@example.com
  [recon-ng][default][pwnedemail] > run
  ```  
  This would query breach databases for the email. Recon-ng has modules for many tasks (e.g., `profiles-namechk` for username search, `contacts` for gathering email contacts via search engines, etc.), which you run in similar fashion. It also supports one-shot CLI usage with `recon-cli` for running a single module without the console.

- **Common Use:** Recon-ng is commonly used to **structure an investigation**. You might start a Recon-ng workspace for your target and run a series of modules: for instance, a **Google search for the person’s name**, then a **LinkedIn scraper module** to find occupational info, then an **email leak check**, etc. All findings go into Recon-ng’s database. Investigators like its ability to **export results** (e.g., to HTML or CSV) using reporting modules when the recon is done ([Recon-NG Tutorial | HackerTarget.com](https://hackertarget.com/recon-ng-tutorial/#:~:text=Recon,results%20to%20different%20report%20types)). In short, Recon-ng is a powerful all-in-one environment to script and record the footprinting process.

### LittleBrother 
LittleBrother is an OSINT tool focused on gathering personal information, primarily geared towards individuals in France, Switzerland, Belgium, and surrounding regions. It compiles various modules to search by name, username, phone number, and other criteria in public databases. For example, LittleBrother can query social media, public records, and phone directories specific to those countries. Despite its regional focus, it can still be useful more broadly for basic person searches.

- **Install:** Not typically in package managers; install by cloning its GitHub repository (`lulz3xploit/LittleBrother`) and running the Python script. Requires Python3 and some modules.  
- **Example Usage:**  
  ```bash
  python3 LittleBrother.py
  ```  
  LittleBrother presents an interactive menu. You might choose an option like “1) Username lookup” or “2) Name search” and then enter the target’s details. For example, selecting the phone lookup module and entering a number will attempt to retrieve the name or address associated with it (using public phonebook APIs). The interface guides you through each step.

- **Common Use:** Best for **initial person searches** when dealing with targets from Western Europe. Investigators use it to quickly check if a person’s name appears in **public registries**, to find **social media profiles by alias**, or to do a **reverse phone lookup**. Because LittleBrother aggregates several search APIs (some country-specific), it’s a convenient starting point especially for French-speaking OSINT investigations.

### PhoneInfoga 
PhoneInfoga specializes in scanning and OSINT footprinting of **phone numbers**. It gathers basic info about a phone number such as the country of origin, region, carrier, and line type (mobile or landline) ([GitHub - sundowndev/phoneinfoga: Information gathering framework for phone numbers](https://github.com/sundowndev/phoneinfoga#:~:text=PhoneInfoga%20is%20one%20of%20the,help%20investigating%20on%20phone%20numbers)) ([GitHub - sundowndev/phoneinfoga: Information gathering framework for phone numbers](https://github.com/sundowndev/phoneinfoga#:~:text=,REST%20API%20and%20Go%20modules)). Beyond that, PhoneInfoga leverages external resources (like phone number reputation databases, search engines, and VoIP provider lookups) to discover if the number is linked to any online accounts or if it appears in any incident reports.

- **Install:** Available as a compiled binary on its GitHub (sundowndev/PhoneInfoga), which runs on Linux. There’s also an AUR package (`phoneinfoga-bin`). Simply downloading the binary or using Docker is common.  
- **Example Usage:**  
  ```bash
  phoneinfoga scan -n "+1 202-555-0143"
  ```  
  This will run a scan on the number `+1 202-555-0143`. The output will show the number’s international format, country and location (e.g., Washington, D.C., USA), the carrier (if available), and line type. It will then perform OSINT lookups: for instance, it might check if the number is listed on spam reporting sites, or try to see if any social media profiles include that number.

- **Common Use:** Investigators use PhoneInfoga when they have a target’s phone number and want to **validate it and gather leads**. Typical use cases include: confirming the number’s legitimacy and region (useful in fraud investigations), checking if the number has been flagged in **scam/spam databases**, and discovering if the number is linked to messaging apps or social media (which can hint at the owner’s identity). It’s an essential tool when a phone number is one of the starting data points in an OSINT investigation, ensuring you don’t overlook a key detail about the number itself.

## Email Discovery and Investigation

Email addresses are rich sources of OSINT data. This stage focuses on finding email addresses associated with a person and investigating those emails for additional information (like data breaches, social accounts, or related identities). The tools below help enumerate email addresses and enrich them with OSINT.

### theHarvester 
theHarvester is one of the classic tools to gather email addresses (and names, subdomains, etc.) related to a target domain or person ([OSINT: Scraping email Addresses with TheHarvester](https://www.hackers-arise.com/post/osint-scraping-email-addresses-with-theharvester#:~:text=Summary)). It works by scraping public sources: search engines (Google, Bing, etc.), key servers, breach databases, and more. In an individual-focused investigation, theHarvester is useful if you know a domain the person is associated with (e.g., their employer or personal website) – you can find all emails on that domain, which often yields the target’s email and potentially colleagues or aliases.

- **Install:** Included in many pentest distributions (in Arch, available via BlackArch repo or AUR). For example, on Kali Linux it’s pre-installed. On Arch, you can use `yay -S theharvester`. Alternatively, `pip install theHarvester`.  
- **Example Usage:**  
  ```bash
  theHarvester -d example.com -b google
  ```  
  This command searches for email addresses on the domain `example.com` using Google as the data source. You can replace `-b google` with other sources (or `-b all` to use all available engines). For instance, if investigating John Doe and you know he’s connected to `doe.org`, running `theHarvester -d doe.org -b all` will scrape the web for any emails ending in `@doe.org`. Results might show addresses like `john@doe.org`, which would directly give you the target’s email if it’s publicly mentioned. The tool will also list any named individuals or hosts it found alongside the emails.

- **Common Use:** OSINT investigators often use theHarvester early when they have a domain but need to get **employee or user emails** ([OSINT: Scraping email Addresses with TheHarvester](https://www.hackers-arise.com/post/osint-scraping-email-addresses-with-theharvester#:~:text=Summary)). For a person, if you know where they work or have a personal domain, theHarvester can quickly pull any email addresses tied to that domain that are exposed online. It’s commonly used to find a target’s **work email** or to verify if a leaked email (from a breach) is associated with a particular organization. While it’s excellent for domain-based email collection, note that it’s less about a single known email and more about discovering emails in the first place.

### Mosint 
Mosint is an **automated email OSINT tool** that consolidates a wide range of checks and queries for a given email address ([GitHub - alpkeskin/mosint: An automated e-mail OSINT tool](https://github.com/alpkeskin/mosint#:~:text=%2A%20Fast%20and%20simple%20email,Output%20to%20JSON%20file)) ([Open Source Intelligence (OSINT): Mosint, The Versatile Email Address Search Tool](https://www.hackers-arise.com/post/open-source-intelligence-osint-the-versatile-email-address-search-tool#:~:text=Mosint%20is%20a%20powerful%20addition,and%20more%20flexible%20reporting%20options)). Written in Go, it’s designed to be fast and simple: given one target email, Mosint will verify if the email is valid, check for social media accounts linked to it, look up data breaches and password leaks, find related emails/domains, search pastebin dumps, perform basic domain/IP OSINT on any related domains, and output results to a JSON (for easy reporting) ([GitHub - alpkeskin/mosint: An automated e-mail OSINT tool](https://github.com/alpkeskin/mosint#:~:text=Image%3A%20mosint)) ([GitHub - alpkeskin/mosint: An automated e-mail OSINT tool](https://github.com/alpkeskin/mosint#:~:text=mosint%20example%40email)). In other words, Mosint tries to be a one-stop shop for investigating a single email address.

- **Install:** Available via AUR (`mosint`) or by using Go (`go install github.com/alpkeskin/mosint/v3/cmd/mosint@latest`). After installing, you’ll need to configure API keys (for breach checks, etc.) in `~/.mosint.yaml` for best results ([GitHub - alpkeskin/mosint: An automated e-mail OSINT tool](https://github.com/alpkeskin/mosint#:~:text=API%20key%20required)) (Mosint will still do what it can without keys, but some data like certain breach lookups require API access).  
- **Example Usage:**  
  ```bash
  mosint target_email@example.com
  ```  
  That’s it – Mosint will then produce output for `target_email@example.com`. For example, it will tell you if the email format looks valid and whether the address likely exists, then list any **social media services** where that email is registered (for instance, “Found account on Facebook/Twitter/etc.” if applicable) ([GitHub - alpkeskin/mosint: An automated e-mail OSINT tool](https://github.com/alpkeskin/mosint#:~:text=%2A%20Fast%20and%20simple%20email,DNS%2FIP%20Lookup)). It will check known breach databases like HaveIBeenPwned and others for any past password leaks involving the email. It also searches for the email in public paste sites, and might report “related emails” (common alias or the same user on different domains), plus basic DNS info for the email’s domain. The output can be saved to JSON for later analysis.

- **Common Use:** Mosint shines when you **already have an email address** of a target and want to pivot off of it. Investigators use it to quickly get a snapshot of everything related to that email: *Has it been pwned? Where has it appeared? What other usernames or domains are linked to it?* According to research, Mosint can reveal password dump data, websites associated with the email, and even approximate geolocation clues (e.g., if an IP was tied to an email in a breach) ([Open Source Intelligence (OSINT): Mosint, The Versatile Email Address Search Tool](https://www.hackers-arise.com/post/open-source-intelligence-osint-the-versatile-email-address-search-tool#:~:text=integration%20of%20Google%20search%2C%20DNS,and%20more%20flexible%20reporting%20options)). It overlaps with what separate tools like haveibeenpwned, holehe, and others do, but in one go. Commonly, one might run Mosint on a personal email to gather leads on **which social networks to investigate** or **which breaches to obtain further info from**, then use specialized tools for deeper dives in those areas.

### Holehe 
Holehe is a focused OSINT tool for discovering **accounts linked to an email address** ([GitHub - megadose/holehe: holehe allows you to check if the mail is used on different sites like twitter, instagram and will retrieve information on sites with the forgotten password function.](https://github.com/megadose/holehe#:~:text=Efficiently%20finding%20registered%20accounts%20from,emails)) ([Holehe OSINT — Email to Registered Accounts | by Jayvin Gohel | Medium](https://th3m4rk5man.medium.com/holehe-osint-email-to-registered-accounts-b21bbd34d029#:~:text=Holehe%20checks%20if%20an%20email,and%20more%20than%20120%20others)). It checks over 120 websites to see if an account exists with the given email, primarily by leveraging password reset or registration pages (in a way that does not alert the target). The idea is that many people reuse the same email for multiple social media, forums, or services; Holehe will quickly show, for example, “This email is registered on Twitter, Instagram, Imgur, Pinterest, … etc.” which is a goldmine for an investigator.

- **Install:** Installable via pip (`pip3 install holehe`) or from AUR (`holehe`). After installation, simply running `holehe` is ready to go – no API keys required for the basic usage, since it uses public web queries.  
- **Example Usage:**  
  ```bash
  holehe test@gmail.com
  ```  
  This will output a list of sites and whether `test@gmail.com` is associated with an account on each. By default, Holehe will attempt the check in a manner that doesn’t trigger emails to the target (e.g., using “Forgot password” pages to see if the site says “account does not exist”). The result might look like: 

  - Green entries (account exists) – e.g., *Twitter: email registered*, *Instagram: email registered*, *Github: email registered*  
  - Purple (account not found) – sites where that email isn’t used.  
  - Red (check not performed) – if rate-limited or error on some sites.

  You can also add options like `--only-used` to display only the sites where the email was found, or `-C` to output results to a CSV file ([Holehe OSINT — Email to Registered Accounts | by Jayvin Gohel | Medium](https://th3m4rk5man.medium.com/holehe-osint-email-to-registered-accounts-b21bbd34d029#:~:text=%2A%20,default%2010)).

- **Common Use:** Holehe is commonly run once you know someone’s email to **map out their online presence**. For example, if investigating an email like `johndoe@gmail.com`, Holehe might reveal that this email has an **Instagram account (probably under the same username), a Twitter account, and accounts on lesser-known forums or gaming sites**. That instantly tells an OSINT researcher which platforms to dig into for content. It’s also used in the opposite scenario: if you find an email in a data breach or leaked list and want to identify the person behind it, seeing where that email is registered can provide clues to their identity. In summary, Holehe’s role is to enumerate the *breadth* of an email’s usage across the internet – a key step in personal footprinting ([GitHub - megadose/holehe: holehe allows you to check if the mail is used on different sites like twitter, instagram and will retrieve information on sites with the forgotten password function.](https://github.com/megadose/holehe#:~:text=Efficiently%20finding%20registered%20accounts%20from,emails)).

### h8mail 
h8mail is an OSINT tool aimed at **finding compromised passwords and data breaches associated with emails** ([GitHub - khast3x/h8mail: Email OSINT & Password breach hunting tool, locally or using premium services. Supports chasing down related email](https://github.com/khast3x/h8mail#:~:text=Image%3A%20Docker%20Pulls%20h8mail%20is,torrent)). Unlike Holehe (which checks for account existence), h8mail focuses on breach data. It can query multiple breach databases and APIs (some free, some requiring API keys) to see if the target email appears in dumps, and if so, retrieve leaked passwords, hashes, or other info. It can also use local breach data (like the “Collection #1” or the massive BreachCompilation torrent) if you have it on disk, to search offline ([Search for sensitive data using theHarvester and h8mail tools | by Grzegorz Piechnik | Medium](https://medium.com/@gpiechnik/search-for-sensitive-data-using-theharvester-and-h8mail-tools-d2a3772d2a32#:~:text=In%20a%20word%20of%20introduction,command)).

- **Install:** Install via pip (`pip3 install h8mail`). Configuration of API keys for services like HaveIBeenPwned, Hunter.io, etc., can be done via a config file or environment variables. Optionally, download breach data (like the BreachCompilation) for offline use.  
- **Example Usage:**  
  1. **Simple online check:**  
     ```bash
     h8mail -t "john.doe@example.com" -o results.txt
     ```  
     This will search through the APIs configured (for example, HIBP) for `john.doe@example.com` and output any findings to `results.txt`. If the email was found in known breaches, you might see results showing which breaches (e.g., *“Appears in LinkedIn 2016 breach”*). With some APIs or configurations, you might get password hashes or partial passwords.  
  2. **Using local breach data:** Suppose you have the BreachCompilation dataset unzipped in `./BreachCompilation`. You could run:  
     ```bash
     h8mail -t targets.txt -bc ./BreachCompilation/
     ```  
     where `targets.txt` contains one or multiple email addresses. h8mail will then scan the huge local text files for those emails. This is faster and more detailed (no API limits) if you have the data. The output might list cracked passwords or hash snippets from the leaks for each target email ([Search for sensitive data using theHarvester and h8mail tools | by Grzegorz Piechnik | Medium](https://medium.com/@gpiechnik/search-for-sensitive-data-using-theharvester-and-h8mail-tools-d2a3772d2a32#:~:text=In%20a%20word%20of%20introduction,command)).

- **Common Use:** h8mail is used when investigating a person’s **security exposure** or to gather potential passwords for pivoting (in a red-team scenario). In pure OSINT terms, finding that a target’s email was in a breach can reveal **old usernames, linked services, or personal info** (for instance, a breach might include their backup email or a phone number). It is often run in conjunction with other email OSINT tools: one workflow is *“Use theHarvester/Holehe to find emails, then run h8mail on those emails to see if they’ve been pwned.”* If a target reuses passwords, h8mail might uncover a password that can then be used to access one of their accounts (if ethically within scope). Even if not, it provides insight into which sites the person used and the scope of their online presence via breach records ([Search for sensitive data using theHarvester and h8mail tools | by Grzegorz Piechnik | Medium](https://medium.com/@gpiechnik/search-for-sensitive-data-using-theharvester-and-h8mail-tools-d2a3772d2a32#:~:text=In%20a%20word%20of%20introduction,command)). Always handle any discovered passwords or sensitive data with care and within legal/ethical boundaries.

## Username Enumeration

People often use the same username across multiple websites. Username enumeration tools help find all profiles associated with a given handle or alias. This can significantly expand what you know about a person by linking their presence on different platforms.

### Sherlock 
Sherlock is a popular and powerful username-checking tool that hunts down social media profiles by a given username across hundreds of platforms ([Open-Source Intelligence(OSINT): Sherlock - The Ultimate Username Enumeration Tool](https://www.hackers-arise.com/post/open-source-intelligence-osint-sherlock-the-ultimate-username-enumeration-tool#:~:text=Sherlock%20scans%20hundreds%20of%20websites,GitHub%2C%20and%20GitLab%E2%80%94among%20many%20others)). It’s essentially a brute-force searcher: given a username, Sherlock will query around 300–400 websites (social networks, forums, coding sites, etc.) to see if that username exists on each, and report back the URLs of matching profiles ([Open-Source Intelligence(OSINT): Sherlock - The Ultimate Username Enumeration Tool](https://www.hackers-arise.com/post/open-source-intelligence-osint-sherlock-the-ultimate-username-enumeration-tool#:~:text=Sherlock%20scans%20hundreds%20of%20websites,GitHub%2C%20and%20GitLab%E2%80%94among%20many%20others)). It’s fast and has a relatively low false-positive rate, making it a go-to for username OSINT.

- **Install:** Can be installed via AUR (`sherlock-git`) or pip (`pip install sherlock-find`). However, many prefer to clone the GitHub repo (sherlock-project/sherlock) and run it directly with Python for the latest version. After installation, use the `sherlock` command.  
- **Example Usage:**  
  ```bash
  sherlock johndoe93
  ```  
  This will start scanning for the username **`johndoe93`** on dozens of sites. As output, Sherlock will list URLs for any found profiles. For example, you might see:  
  - *Twitter: https://twitter.com/johndoe93 – **Found!***  
  - *Instagram: https://www.instagram.com/johndoe93 – **Found!***  
  - *GitHub: https://github.com/johndoe93 – **Found!***  
  - *Facebook: Not Found* (and so on…)  
  Each “Found” means the site returned a page indicating an account with that username exists (Sherlock directly checks the URL or uses site-specific logic). In a few seconds or minutes, you get a comprehensive list of all platforms where **`johndoe93`** has an account. (It’s wise to manually verify critical findings in a browser, as very rarely a common username might belong to different people on different sites.)

- **Common Use:** Sherlock is typically run when you have a username or alias that the target uses (for example, you discovered a person’s gamer tag or an email prefix that looks like a username) and you want to see their entire **online footprint of accounts**. It’s extremely useful for **linking identities**: someone might use the same handle on a dating site, a coding forum, and a social network. Investigators use Sherlock to reveal these connections quickly ([Open-Source Intelligence(OSINT): Sherlock - The Ultimate Username Enumeration Tool](https://www.hackers-arise.com/post/open-source-intelligence-osint-sherlock-the-ultimate-username-enumeration-tool#:~:text=Sherlock%20scans%20hundreds%20of%20websites,GitHub%2C%20and%20GitLab%E2%80%94among%20many%20others)). For instance, finding a target’s Reddit and GitHub from their Instagram username can provide a trove of personal info they shared on those platforms. Sherlock’s speed and breadth (400+ sites including mainstream and niche platforms) make it an invaluable OSINT tool for username enumeration – essentially creating a map of where a person is present online.

### Social Analyzer 
Social Analyzer is a more extensive profile-finding framework that goes beyond simple username checking. It can search for a person’s profile by **username, full name, email, or phone** across over 1000 social media sites and websites ([GitHub - qeeqbox/social-analyzer: API, CLI, and Web App for analyzing and finding a person's profile in 1000 social media \ websites](https://github.com/qeeqbox/social-analyzer#:~:text=Image)). It includes an API, CLI, and web interface. One of its strengths is an intelligent scoring system to reduce false positives: it doesn’t just check if a username exists, but can analyze page content or use OCR on profile images, etc., to determine likelihood of a match, giving a confidence rating ([GitHub - qeeqbox/social-analyzer: API, CLI, and Web App for analyzing and finding a person's profile in 1000 social media \ websites](https://github.com/qeeqbox/social-analyzer#:~:text=Social%20Analyzer%20,use%20during%20the%20investigation%20process)). It’s useful when you have slightly varying aliases or want to cover obscure platforms that Sherlock might not include.

- **Install:** Not typically in distro repos; you can install via pip or use Docker. For CLI, install the Python package `social-analyzer`. Thereafter, use the `social-analyzer` command. (Detailed usage may require reading its docs due to many options and modules.)  
- **Example Usage:** To illustrate, suppose you want to find profiles for the name “Jane Doe” on social media:  
  ```bash
  social-analyzer -f name -q "Jane Doe" -o jane_profiles.json
  ```  
  Here, `-f name` tells it you are searching by full name (not by username), and `-q "Jane Doe"` is the query. It will search various networks for likely matches (which can include usernames resembling the name, or profile names on sites). The results are saved to a JSON file. Each found profile might include a score (0–100) indicating how confident the tool is that it’s the same person ([GitHub - qeeqbox/social-analyzer: API, CLI, and Web App for analyzing and finding a person's profile in 1000 social media \ websites](https://github.com/qeeqbox/social-analyzer#:~:text=detection%20modules%2C%20and%20you%20can,use%20during%20the%20investigation%20process)). Alternatively, to use it like Sherlock by username:  
  ```bash
  social-analyzer -f username -q johndoe93
  ```  
  would check a huge list of sites for that username. Social Analyzer can also run in a web app mode for interactive use, but for our purposes the CLI mode gives structured output that can be further analyzed.

- **Common Use:** Social Analyzer is chosen when an investigator wants a **broader or smarter search** than a straightforward username check. For example, if a person uses slight variations of a name (Jane_Doe, JaneDoe123, JDoe) on different sites, Social Analyzer’s name search and permutation capabilities can catch those. It’s also used to correlate profiles: it can take multiple known accounts of a person as input and try to find links between them. Because it can incorporate techniques like image analysis and has a large database of sites, it’s helpful for finding someone on more **obscure platforms (dating sites, regional networks, etc.)** that other tools might miss ([8 open-source OSINT tools you should try - Help Net Security](https://www.helpnetsecurity.com/2023/08/22/open-source-osint-tools/#:~:text=8%20open,across%20social%20media%20and%20websites)) ([GitHub - qeeqbox/social-analyzer: API, CLI, and Web App for analyzing and finding a person's profile in 1000 social media \ websites](https://github.com/qeeqbox/social-analyzer#:~:text=Image)). The downside is it can be a bit slower or more complex, but the comprehensive coverage and reduced false positives (via its scoring mechanism) can save time in manual verification. In summary, Social Analyzer is like a supercharged, all-angle approach to profile discovery, useful in complex cases where simple enumeration isn’t enough.

*(Other tools in this category include **Maigret** (similar to Sherlock, scanning many sites with some additional info gathering) and **Namechk** (online service/CLI to check username availability). In practice, Sherlock and Social Analyzer are among the most widely used for breadth of coverage.)*

## Social Media Analysis

After identifying a person’s presence on social media, the next step is to gather intelligence from those platforms. Social media analysis tools focus on extracting user data, posts, connections, and other content directly from social networks. Many of these tools operate via the platforms’ APIs or by scraping public (or your authorized) data. Below are tools for some major platforms and general tactics.

### Twint (Twitter Intelligence) 
Twint is an advanced Twitter scraping tool that allows OSINT investigators to collect Tweets and user data **without using the Twitter API or requiring authentication** ([GitHub - twintproject/twint: An advanced Twitter scraping & OSINT tool written in Python that doesn't use Twitter's API, allowing you to scrape a user's followers, following, Tweets and more while evading most API limitations.](https://github.com/twintproject/twint#:~:text=Twint%20is%20an%20advanced%20Twitter,profiles%20without%20using%20Twitter%27s%20API)). This is important because it bypasses API rate limits and restrictions. With Twint, you can gather a target’s entire tweet history (beyond the last 3200 tweets limit of official API), their followers, who they follow, likes, and even search tweets for keywords – all from the command line ([GitHub - twintproject/twint: An advanced Twitter scraping & OSINT tool written in Python that doesn't use Twitter's API, allowing you to scrape a user's followers, following, Tweets and more while evading most API limitations.](https://github.com/twintproject/twint#:~:text=Twint%20utilizes%20Twitter%27s%20search%20operators,really%20creative%20with%20it%20too)). Twint uses Twitter’s search queries under the hood.

- **Install:** Available via pip (`pip install twint`) or AUR (`twint`). Twint has a few Python dependency version issues at times, so you might need to use Python 3.7–3.8 for full functionality. There’s no need for API keys or a Twitter login.  
- **Example Usage:**  
  ```bash
  twint -u jack -o jack_tweets.csv --csv
  ```  
  This fetches all tweets from the user with username `jack` (Twitter’s founder) and outputs them to a CSV file. The `-u` flag specifies the username. Twint will start from their most recent tweet and scroll back through time, scraping each tweet’s text, timestamp, tweet ID, etc., until it reaches the beginning of the account. Another example:  
  ```bash
  twint -s "from:jack since:2023-01-01 until:2023-12-31 filter:replies"
  ```  
  This uses Twint’s search mode (`-s`) to find all replies by @jack in the year 2023. Twint supports many search operators (basically any Twitter advanced search query can be put after `-s`). You can also gather followers:  
  ```bash
  twint -u jack --followers -o jack_followers.txt
  ```  
  This will list all usernames of accounts following @jack. Similar flags exist for following (`--following`), favorites (`--favorites` to get tweets a user has liked), and more.

- **Common Use:** Twint is the go-to tool for **mining Twitter data** in OSINT investigations. Common patterns include: 
  - **Timeline analysis:** Downloading all of a target’s tweets to analyze their interests, timeline of events, or connections. 
  - **Keyword searches:** Finding every mention of a company, email, or keyword by various users (great for discovering if the target talked about something specific). 
  - **Followers/Following mapping:** Exporting who a target follows or who follows them, which can identify associates or secondary targets. 
  - **Geolocation:** Twint can filter tweets by location or show if the target’s tweets have geo-coordinates. 
Because it doesn’t need API keys, investigators can use Twint freely to collect large amounts of Twitter intel that would be otherwise time-consuming or impossible to get via the official API ([GitHub - twintproject/twint: An advanced Twitter scraping & OSINT tool written in Python that doesn't use Twitter's API, allowing you to scrape a user's followers, following, Tweets and more while evading most API limitations.](https://github.com/twintproject/twint#:~:text=Twint%20utilizes%20Twitter%27s%20search%20operators,really%20creative%20with%20it%20too)). It’s especially useful now that API access to Twitter is more restricted – Twint fills that gap for OSINT needs. Do note that as Twitter’s front-end changes, Twint occasionally needs updates to keep working (being an unofficial scraper).

### Osintgram 
Osintgram is an OSINT tool specifically for Instagram. It provides an interactive shell to retrieve a variety of information from a target Instagram account using only the account’s username ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=Tools%20and%20Commands)). By logging in with your own throwaway Instagram credentials (required to access Instagram data), Osintgram can fetch the target’s followers, who the target is following, photos, captions, stories, tagged posts, and even attempt to extract things like email addresses or phone numbers from the profile or posts ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=Osintgram%20offers%20an%20interactive%20shell,You%20can%20get)). It essentially automates a lot of what an investigator would manually do on Instagram, but faster and in bulk.

- **Install:** Available in AUR (`osintgram`) which pulls from GitHub (Datalux/Osintgram). After install, you must supply Instagram login credentials (in a config file `credentials.ini`). Be mindful to use a burner account for this to avoid your real account being flagged by Instagram’s anti-scraping measures ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=Warning%3A%20It%20is%20advisable%20to,account%20when%20using%20this%20tool)) ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=1,a%20code%2C%20confirm%20email%2C%20etc)).  
- **Example Usage:**  
  Start Osintgram in interactive mode for a target:  
  ```bash
  osintgram target_username
  ```  
  (If installed via AUR/pip, the `osintgram` command launches the tool; otherwise run `python3 main.py target_username`.) This drops you into an `Osintgram >` prompt. From here you can run commands, such as:  
  - `followers` – to get the list of the target’s followers ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=,Get%20users%20followed%20by%20target)).  
  - `followings` – to list whom the target is following ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=,Get%20email%20of%20target%20followers)).  
  - `info` – to get the target’s profile info (bio, #posts, etc.) ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=,Download%20user%27s%20stories)).  
  - `photos` – to download all photos from the target’s feed to an output folder ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=,Download%20user%27s%20profile%20picture)).  
  - `captions` – to retrieve captions of all posts (useful for keyword scanning) ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=,phone%20number%20of%20target%20followers)).  
  - `stories` – to download current stories.  
  You can also run a single command non-interactively, for example:  
  ```bash
  osintgram target_username --command followers
  ```  
  would print out all followers directly. Osintgram outputs data into an `output` directory as well (for downloaded images, etc.).

- **Common Use:** Investigators use Osintgram to **collect target Instagram data systematically**. Common patterns:
  - **Building association lists:** Using `followers` and `followings` to identify close connections of the person (friends, family, colleagues).
  - **Content archiving:** Downloading all photos and stories for offline analysis. This is useful because Instagram content can be transient (stories, or posts might be deleted).
  - **Profile analysis:** Extracting info like profile picture (`propic` command downloads it) and checking if the bio or captions contain an email, phone number, or other personal info (Osintgram has commands like `email` or `phone` that attempt to find those in the profile).
  - **Tagged relations:** The `tagged` and `wtagged` commands show who the target has tagged or who has tagged the target in posts ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=,of%20user%20who%20tagged%20target)), revealing social circles or other accounts of the same person.
  
  Essentially, Osintgram automates Instagram reconnaissance that would be tedious by hand, giving an investigator a trove of data to work with. Keep in mind Instagram’s policies: excessive or improper use might trigger challenges on the account you log in with ([GitHub - Datalux/Osintgram: Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram account of any users by its nickname](https://github.com/Datalux/Osintgram#:~:text=1,a%20code%2C%20confirm%20email%2C%20etc)), so use rate limiting if needed and always use a throwaway IG account.

### Instaloader 
Instaloader is another tool for Instagram, focused on downloading content. It’s a command-line Python tool (and library) that can download all photos, videos, stories, highlights, and metadata from Instagram profiles (including public profiles or private ones if you have login access). While not an “analysis” tool per se, it’s very useful in OSINT to **archive an Instagram account’s content** for analysis with other tools (like searching images for EXIF data or scanning posts for mentions).

- **Install:** `pip install instaloader`. No AUR package needed since pip works out-of-the-box.  
- **Example Usage:**  
  ```bash
  instaloader profile <target_username>
  ```  
  This will create a folder named after the target and start downloading all posts (with captions), the profile picture, and basic profile info. For a private account, you’d use `instaloader -l YOURUSERNAME <target>` to login first. Other usage:
  - Download stories: `instaloader --stories <target_username>` 
  - Download highlights or tagged posts similarly by adding flags (`--highlights`, `--tagged`).  
  Instaloader saves data with the original timestamps and can be run repeatedly to get new posts since the last run.

- **Common Use:** Often used when you have identified an Instagram profile of interest (maybe via Osintgram or Sherlock) and you want to **back up everything for offline examination**. Investigators might then comb through the downloaded captions or run image analysis on the photos. Instaloader ensures you don’t lose data if the person cleans up their account or if you want to work without constantly querying Instagram. In reporting, having the actual images and posts can be vital evidence.

*(Similar tools exist for other platforms: e.g., **Tiktok OSINT** might involve manually using TikTok’s web API or third-party scrapers; **Facebook** is notoriously difficult due to protections, but one might use the `facebook-scraper` Python package to get public page data or utilize Graph API for authorized queries; **LinkedIn** data is often gathered via tools like **Maigret** or search engine dorks since direct scraping is hard without being detected.)*

### GHunt 
GHunt is a specialized tool for investigating **Google accounts** (Gmail addresses or Google IDs). Given a Gmail address, GHunt can attempt to gather information like the account’s Google ID (a unique number), which can then be used to find public data associated with that account – for example, YouTube channel, Google Photos shared albums, or public Google Calendar events. It can even sometimes reveal the user’s name or profile photo if they have certain Google services exposed. GHunt essentially exploits misconfigurations or public-by-default data in Google services to profile a Google account owner.

- **Install:** GHunt is on GitHub (mxrch/GHunt). It requires Python and you’ll need to provide some cookie values from a logged-in Google account (to perform certain searches via Google). This setup is a bit technical (involves copying your SID, LSID cookies into GHunt’s config).  
- **Example Usage:** After setup, a typical GHunt command is:  
  ```bash
  python3 ghunt.py email target@gmail.com
  ```  
  This will output information about the Google account associated with `target@gmail.com`. For instance, it might show an account ID, the creation date of the Gmail (if it can be inferred from Google Voice), whether Google Maps reviews by that account are visible, etc. Another command:  
  ```bash
  python3 ghunt.py hunt target@gmail.com
  ```  
  goes deeper, checking for things like public Google Photos albums, YouTube channels linked to that email, and so on. If the target email is actually a Google Account, GHunt can sometimes retrieve the user’s name (e.g., if they have a public YouTube profile under their real name).

- **Common Use:** GHunt is useful when an investigator only has a Gmail address and needs to pivot. For example, it can uncover a target’s YouTube channel from their email, which then gives you all their videos, subscriptions, and comments. It can also reveal if an email is tied to services like Google Drive or Maps (though direct data from those is not accessible without auth, just knowing they exist is useful). If the person has left any part of their Google profile public (like a photo or name), GHunt can retrieve that as well. Essentially, GHunt is about **mining the Google ecosystem** for personal data – an often overlooked angle, since Google accounts tie into so many services.

## Reporting and Documentation

In an OSINT investigation, after gathering all information, the final step is compiling findings into a report. This includes organizing data, creating visualizations if needed, and documenting the evidence with sources. While much of “reporting” is manual (writing the report, analyzing data), there are tools and features to assist in this stage:

### Using Recon-ng and SpiderFoot for Reporting 
As mentioned, both Recon-ng and SpiderFoot have **report output capabilities** built-in. Recon-ng can export data from its database to various formats (CSV, JSON, HTML) using reporting modules ([Recon-NG Tutorial | HackerTarget.com](https://hackertarget.com/recon-ng-tutorial/#:~:text=Recon,results%20to%20different%20report%20types)). For example, after collecting emails and social links in Recon-ng, you could run the `report/html` module to generate an HTML report of all findings. This gives a quick structured output that can be included as an appendix or used to cross-verify data when writing the final report.

SpiderFoot’s web UI likewise can generate an HTML report or allow you to export results of a scan. If you ran a SpiderFoot scan on a person’s name, you can export all the found links, emails, etc., as an HTML page or XML/CSV. This is very helpful to ensure **no findings are missed** when writing the narrative of the report.

**Common practice:** Investigators will often take the CSV outputs from tools like these and import them into spreadsheet software or a database to further analyze or de-duplicate information before writing conclusions. The automation tools ensure that all data points are logged so the investigator can reference them when needed.

### Dradis or Case Management Tools 
While not OSINT-specific, tools like **Dradis** (an open-source reporting tool used in pentesting) can be used to organize OSINT findings. Dradis lets you create notes, import data, and collaborate on a report. An investigator might copy-paste important findings (like key email addresses, screenshots of profiles, etc.) into Dradis to keep track of them. This is more about workflow organization than automatic reporting.

Another approach is using a **Jupyter Notebook** to document as you go – some OSINT analysts do this to mix code (for using APIs) and documentation in one place, then export to HTML for reporting.

### Maltego for Visualization 
Although Maltego CE is a graphical tool (not command-line), it’s worth mentioning for reporting because it helps visualize the connections between data points. In an investigation focused on individuals, Maltego can be used to create relationship graphs: for example, an email node connected to social media account nodes, connected to domain nodes, etc. You can import the data you gathered (Maltego has community “transforms” for things like haveibeenpwned, social networks, etc., or you can input data manually) and then produce a nice chart of how everything is linked.

In the report’s final form, including a Maltego chart or other diagram can make it easier for the reader to see the big picture of the person’s OSINT profile – which email belongs to what, which usernames were found where, who their connections are, etc. Maltego CE is free (with registration) and often used alongside the above CLI tools: the CLI tools gather raw data, and Maltego is used to visualize and spot connections.

### Reporting Write-up 
Ultimately, the OSINT tools will feed into a written report. The report typically will have sections like *Summary*, *Findings* (perhaps broken down by OSINT category: Email findings, Social Media findings, etc.), and *Conclusion*. Ensure that every important detail discovered with the tools is documented, cited (even if just as “Found via SpiderFoot from Google search”), and where appropriate, screenshots are included (e.g., a screenshot of the target’s Facebook profile as evidence).

Many of the tools we’ve discussed allow output to formats friendly for inclusion in reports:
- **JSON/CSV** outputs (from Mosint, SpiderFoot, Recon-ng, Social Analyzer) can be filtered and copied into tables in the report (e.g., a table of all emails found, with sources).
- **Images** and media (from Osintgram, Instaloader, etc.) can be included as figures in the report to support findings.
- **Timeline data** (from Twint, for example) can be used to create a timeline of activity if that’s relevant (some investigators use tools like Timesketch or just Excel to plot when a person posted what).

In summary, **reporting stage** tools help transform the trove of OSINT data into a clear story. Using the export features of OSINT tools and visualization software ensures the final report is not just a dump of data but a coherent narrative backed by solid evidence. The technical tools do the heavy lifting of data gathering; the analyst’s job in reporting is to interpret and present that data effectively.

---

*By following the stages outlined – footprinting, email discovery, username enumeration, social media analysis, and finally, reporting – an investigator can systematically and efficiently research an individual using the arsenal of free OSINT tools available. Each tool above plays a role in the larger process, and combined, they enable a thorough, professional, and well-documented OSINT investigation.* 

**Sources:** The descriptions and examples above reference official documentation and community tutorials for the respective tools, such as SpiderFoot’s features ([SpiderFoot – A Automate OSINT Framework in Kali Linux | GeeksforGeeks](https://www.geeksforgeeks.org/spiderfoot-a-automate-osint-framework-in-kali-linux/#:~:text=target.%20,of%20scanning%20done%20by%20Spiderfoot)), Recon-ng usage guides ([Recon-NG Tutorial | HackerTarget.com](https://hackertarget.com/recon-ng-tutorial/#:~:text=Recon,gathering%20information%20from%20open%20sources)), Sherlock’s capabilities ([Open-Source Intelligence(OSINT): Sherlock - The Ultimate Username Enumeration Tool](https://www.hackers-arise.com/post/open-source-intelligence-osint-sherlock-the-ultimate-username-enumeration-tool#:~:text=Sherlock%20scans%20hundreds%20of%20websites,GitHub%2C%20and%20GitLab%E2%80%94among%20many%20others)), and more, as linked inline. These provide further detail on functionality and real-world usage of the tools.