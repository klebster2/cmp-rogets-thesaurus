import re

import requests
from lxml import html

if __name__ == "__main__":
    # Fetching the HTML data
    url = "https://www.gutenberg.org/cache/epub/10681/pg10681-images.html"

    response = requests.get(url)

    if response.status_code == 200:
        html_content = response.text
    else:
        print("Failed to fetch the HTML data")
        raise SystemExit

    tree = html.fromstring(html_content)

    # Extracting the data
    entries = tree.xpath("//a[starts-with(@id, 'link')]")
    data = []

    for entry in entries:
        if not entry.xpath("text()"):
            continue
        else:
            entry_number = entry.xpath("text()")[0].strip()

        if not entry.xpath("following-sibling::b[1]/text()"):
            continue
        else:
            entry_title = entry.xpath("following-sibling::b[1]/text()")[0].strip()

        content_nodes = entry.xpath(
            "following-sibling::node()[preceding-sibling::hr[1]]"
        )

        content = []
        current_category = ""
        for node in content_nodes:
            if isinstance(node, str):
                if not node.replace("--", "").rstrip():
                    continue
                else:
                    line = node.rstrip()
                    if line and line != "†":
                        if (
                            line.startswith(",")
                            or line.startswith(";")
                            or line.startswith("&c")
                        ):
                            if content:
                                content[-1] += " " + line
                        else:
                            content.append(f"{current_category}\t{line}")
            else:
                if node.tag == "b" and node.xpath(
                    "following-sibling::node()[1][self::i or self::a or self::text()]"
                ):
                    if node.xpath("text()"):
                        current_category = node.xpath("text()")[0].rstrip()
                    continue
                elif node.tag == "a" and node.xpath("@class='pginternal'"):
                    continue
                else:
                    content_text = " ".join(node.xpath(".//text()")).rstrip()
                    if content_text and content_text != "†":
                        if (
                            content_text.startswith(",")
                            or content_text.startswith(";")
                            or content_text.startswith("&c")
                        ):
                            if content:
                                content[-1] += " " + content_text
                        else:
                            content.append(f"{current_category}\t{content_text}")

        if content:
            # Concatenate lines with bracketed explanations to the previous line
            cleaned_content = []
            for line in content:
                if line.strip().startswith("["):
                    if cleaned_content:
                        cleaned_content[-1] += " " + line
                else:
                    cleaned_content.append(line)
            # Combine lines where current category hasn't changed
            final_content = []
            previous_category = None
            for line in cleaned_content:
                category, text = line.split("\t", 1)
                if category == previous_category:
                    final_content[-1] += " " + text
                else:
                    final_content.append(line)
                    previous_category = category

            # Remove redundant periods and merge lists
            final_content = [
                line.replace(" .", ".").replace(" ;", ";") for line in final_content
            ]

            # Remove stray spaces before commas and semicolons
            final_content = [
                line.replace(" ,", ",").replace(" ;", ";") for line in final_content
            ]

            # Split lines at semicolons
            split_content = []
            for line in final_content:
                category, text = line.split("\t", 1)
                parts = text.split(";")
                for part in parts:
                    split_content.append(f"{category}\t{part.rstrip()}")

            _content = ""
            for content in split_content:
                if not entry_number or not entry_title:
                    content += content.replace("\r", "").replace("\n", "").rstrip()
                else:
                    _content += content.replace("\r", "").replace("\n", "").rstrip()
                    data.append(
                        f"{entry_number}\t{entry_title}\t"
                        + re.sub(
                            r"\s+",
                            " ",
                            _content.replace(entry_title, "").replace("\t", " "),
                        )
                    )
                    _content = ""

    # Writing to a TSV file
    with open("rogets_thesaurus.tsv", "w", encoding="utf-8") as file:
        for entry in data:
            file.write(entry + "\n")
