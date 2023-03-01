#!/usr/bin/env python3

import datetime
import logging
import typing
from dataclasses import dataclass

from selenium.webdriver import Chrome, ChromeOptions, DesiredCapabilities
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.ui import WebDriverWait

STARS = 400
LASTCOMMIT = 2 * 365 * 24 * 3600  # 2 years * 365 days * 24 hours * 3600 seconds
INDENT_SIZE = 4
INDENT = " " * INDENT_SIZE

logging.basicConfig(
    format="%(asctime)s %(levelname)s [%(filename)s:%(lineno)d](%(funcName)s) %(message)s",
    level=logging.INFO,
)


def retrieve_integer(s):
    i = 0
    result = None
    while i < len(s):
        c = s[i]
        i += 1
        if c.isdigit():
            if result is None:
                result = c
            else:
                result = result + c
        else:
            if result is None:
                continue
            else:
                return int(result)
    assert False


def repo_exist(repos, r):
    for repo in repos:
        logging.debug(f"repo({repo}) == r({r}):{repo == r}")
        if r == repo:
            return True
    return False


def duplicate_color(repos, r):
    def position(url):
        assert isinstance(url, str)
        if url.endswith(".vim"):
            return url.find(".vim")
        if url.endswith(".nvim"):
            return url.find(".nvim")
        if url.endswith("-vim"):
            return url.find("-vim")
        if url.endswith("-nvim"):
            return url.find("-nvim")
        return -1

    def same(r1, r2):
        r1 = r1.url.split("/")[-1]
        r2 = r2.url.split("/")[-1]
        if r1 == r2:
            return True
        pos1 = position(r1)
        pos2 = position(r2)
        if pos1 <= 0 or pos2 <= 0:
            return False
        base1 = r1[:pos1]
        base2 = r2[:pos2]
        return base1 == base2

    for repo in repos:
        if same(repo, r):
            return True
    return False


def blacklist(repo):
    if repo.url.find("rafi/awesome-vim-colorschemes") >= 0:
        return True
    if repo.url.find("sonph/onehalf") >= 0:
        return True
    if repo.url.find("ghifarit53/tokyonight-vim") >= 0:
        logging.warning(
            " `ghifarit53/tokyonight-vim` is deprecated! please use: https://github.com/folke/tokyonight.nvim"
        )
        return True
    return False


def find_element(driver, xpath):
    WebDriverWait(driver, 30).until(
        expected_conditions.presence_of_element_located((By.XPATH, xpath))
    )
    return driver.find_element(By.XPATH, xpath)


def find_elements(driver, xpath):
    WebDriverWait(driver, 30).until(
        expected_conditions.presence_of_element_located((By.XPATH, xpath))
    )
    return driver.find_elements(By.XPATH, xpath)


def make_driver():
    options = ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--single-process")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--allow-running-insecure-content")
    options.add_argument("--ignore-certificate-errors")
    options.add_argument("--allow-insecure-localhost")
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_experimental_option("useAutomationExtension", False)
    options.add_experimental_option("excludeSwitches", ["enable-automation"])

    desired_capabilities = DesiredCapabilities().CHROME.copy()
    # desired_capabilities["pageLoadStrategy"] = "eager"
    desired_capabilities["acceptInsecureCerts"] = True

    return Chrome(options=options, desired_capabilities=desired_capabilities)


@dataclass
class Repo:
    url: str
    stars: int
    last_update: typing.Optional[datetime.datetime]

    def __str__(self):
        return f"<Repo url:{self.url}, stars:{self.stars}, last_update:{self.last_update.isoformat() if isinstance(self.last_update, datetime.datetime) else None}>"

    def __hash__(self):
        return hash(self.url)

    def __eq__(self, other):
        return isinstance(other, Repo) and self.url == other.url


class Vcs:
    def pages(self):
        i = 0
        while True:
            if i == 0:
                yield "https://vimcolorschemes.com/top"
            else:
                yield f"https://vimcolorschemes.com/top/page/{i+1}"
            i += 1

    def parse_repo(self, element):
        repo = "/".join(
            element.find_element(By.XPATH, "./a[@class='card__link']")
            .get_attribute("href")
            .split("/")[-2:]
        ).strip()
        stars = int(
            element.find_element(
                By.XPATH,
                "./a/section/header[@class='meta-header']//div[@class='meta-header__statistic']//b",
            ).text
        )
        creates_updates = element.find_elements(
            By.XPATH,
            "./a/section/footer[@class='meta-footer']//div[@class='meta-footer__column']//p[@class='meta-footer__row']",
        )
        last_update = datetime.datetime.fromisoformat(
            creates_updates[1]
            .find_element(By.XPATH, "./b/time")
            .get_attribute("datetime")
        )

        return Repo(url=repo, stars=stars, last_update=last_update)

    def parse(self):
        repositories = []
        with make_driver() as driver:
            for page_url in self.pages():
                driver.get(page_url)
                any_valid_stars = False
                for element in find_elements(driver, "//article[@class='card']"):
                    repo = self.parse_repo(element)
                    logging.debug(f"vsc repo:{repo}")
                    if repo.stars < STARS:
                        logging.info(f"vsc skip for stars - repo:{repo}")
                        continue
                    assert isinstance(repo.last_update, datetime.datetime)
                    if (
                        repo.last_update.timestamp() + LASTCOMMIT
                        < datetime.datetime.now().timestamp()
                    ):
                        logging.info(f"vsc skip for last_update - repo:{repo}")
                        continue
                    logging.info(f"vsc get - repo:{repo}")
                    repositories.append(repo)
                    any_valid_stars = True
                if not any_valid_stars:
                    logging.info(f"vsc no valid stars, exit")
                    break
            return repositories


class Acs:
    def parse_repo(self, element):
        a = element.find_element(By.XPATH, "./a").text
        a_splits = a.split("(")
        repo = a_splits[0].strip()
        stars = retrieve_integer(a_splits[1])
        return Repo(url=repo, stars=stars, last_update=None)

    def parse_color(self, driver, tag_id):
        repositories = []
        colors_group = find_element(
            driver,
            f"//main[@class='markdown-body']/h4[@id='{tag_id}']/following-sibling::ul",
        )
        for e in colors_group.find_elements(By.XPATH, "./li"):
            repo = self.parse_repo(e)
            logging.debug(f"acs repo:{repo}")
            repositories.append(repo)
        return repositories

    def parse(self):
        repositories = []
        with make_driver() as driver:
            driver.get(
                "https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme"
            )
            treesitter_colors = self.parse_color(
                driver, "tree-sitter-supported-colorscheme"
            )
            lua_colors = self.parse_color(driver, "lua-colorscheme")
            treesitter_colors.extend(lua_colors)
            for repo in treesitter_colors:
                if repo.stars < STARS:
                    logging.info(f"asc skip for stars - repo:{repo}")
                    continue
                logging.info(f"acs get - repo:{repo}")
                repositories.append(repo)
        return repositories


def format_lazy(repo, duplicated):
    dup_line = (INDENT * 2 + "-- duplicated\n") if duplicated else ""
    return f"""{INDENT}{{
{dup_line}{INDENT*2}'{repo.url}',
{INDENT*2}lazy = true,
{INDENT*2}priority = 1000,
{INDENT}}},
"""


if __name__ == "__main__":
    vcs = Vcs().parse()
    acs = Acs().parse()
    acs.append(Repo(url="folke/tokyonight.nvim", stars=1000, last_update=None))
    cs = []
    with open("get-colors-list.lua", "w") as fp:
        fp.writelines("return {\n")
        fp.writelines(f"{INDENT}-- https://vimcolorschemes.com/\n")
        for repo in sorted(vcs, key=lambda r: r.stars, reverse=True):
            if repo_exist(acs, repo):
                logging.info("vcs repo:{repo} already exist in acs, skip")
            elif blacklist(repo):
                logging.info("vcs repo:{repo} in blacklist, skip")
            else:
                dup = duplicate_color(cs, repo)
                fp.writelines(format_lazy(repo, dup))
                cs.append(repo)
        fp.writelines(
            f"\n{INDENT}-- https://www.trackawesomelist.com/rockerBOO/awesome-neovim/readme/#colorscheme\n"
        )
        for repo in sorted(acs, key=lambda r: r.stars, reverse=True):
            if blacklist(repo):
                logging.info("acs repo:{repo} in blacklist, skip")
            dup = duplicate_color(cs, repo)
            fp.writelines(format_lazy(repo, dup))
            cs.append(repo)
        fp.writelines("}\n")