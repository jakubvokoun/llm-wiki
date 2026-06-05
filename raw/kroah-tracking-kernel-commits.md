# Tracking kernel commits across branches

With all of the different Linux kernel stable releases happening (at least 1 stable branch and multiple longterm branches are active at any one point in time), keeping track of what commits are already applied to what branch, and what branch specific fixes should be applied to, can quickly get to be a very complex task if you attempt to do this manually. So I’ve created some tools to help make my life easier when doing the stable kernel maintenance work, which ended up making the work of tracking CVEs much simpler to manage in an automated way.

This is a post in the series about the Linux kernel CVE release process:
- [Linux kernel versions](http://www.kroah.com/log/blog/2025/12/09/linux-kernel-version-numbers/), how the Linux kernel releases are numbered.
- Tracking kernel commits across branches (this post), how to keep track of Linux kernel commits as they move from the main release branch into the different stable releases in an automated way.
- [Linux kernel security work](http://www.kroah.com/log/blog/2026/01/02/linux-kernel-security-work/)how the Linux kernel security team works to fix reported security bugs.
- [Linux CVE assignment process](http://www.kroah.com/log/blog/2026/02/16/linux-cve-assignment-process/), how the Linux CVE team processes bugs and classifies them as CVEs.
- Linux CVE tools, how a kernel commit is turned into a CVE entry automatically and kept up to date over time (future post).

# Tracking commit flow

As mentioned previously, changes in the stable kernel branches need to go in Linus’s branch first, and then they are “cherry-picked” into the stable kernel branches as needed. When this happens, the commit text is modified to show the original commit id to help people be able to track it correctly.

This modified text has over the years, been standardized in two different ways, due to different tools being used by different stable maintainers, and it happening before the “standard”`-x ` option was added to ` git cherry-pick `, which is why that format is not used.

In a stable commit, the original commit is documented in the first line of the change log, either by saying:

```
` commit SHA1 upstream.`
```

or

```
`[ Upstream commit SHA1 ]`
```

where ` SHA1 ` is the full git commit id of the change in Linus’s main branch.

As an example, when the commit ` 28412b489b08 ("ALSA: usb-audio: Fix NULL pointer deference in try_to_register_card") ` was backported to the stable kernel trees, the first line of the changelog for every branch it was backported to said:

```
`[ Upstream commit 28412b489b088fb88dff488305fd4e56bd47f6e4 ]`
```

while the commit ` 2ad5692db728 ("net: hso: fix NULL-deref on disconnect regression") ` was backported, it contained the line:

```
` commit 2ad5692db72874f02b9ad551d26345437ea4f7f3 upstream.`
```

## Searching for commits by brute force

Because stable commits have the original git commit id in the changelog text itself, it is then possible to search the git logs to find out what branches specific commits have been backported to. This is something that I need to do all the time when applying stable kernel fixes in order to figure out how far back, and to what branches, a stable kernel fix should be applied to.

Searching git all the time is a messy process to do this manually, having to check out, and then walk each branch can be complex, and it can be relatively slow when you are dealing with a source tree the size of the Linux kernel (as of the 6.18 kernel release, the Linux kernel git repo has has 1,863,462 commits in 4,631 different releases).

To help make this easier for myself, I realized many years ago that this should be automated a bit better as running ` git grep ` on different branches just wasn’t cutting it anymore.

As all “lazy” programmers know, a filesystem can be easily used as a simple “database” with quick lookups possible by just walking a directory tree of files (git does this internally when storing uncompressed objects on the filesystem). Using that idea, I created a[simple set of scripts](https://git.sr.ht/~gregkh/linux-stable_commit_tree)that takes the all of the kernel commit changelog texts across all branches and places that information in a separate git repo that consists of just the kernel changelog saved in text files that can then be searched directly without having to worry about branches and all of the actual source code changes in the kernel git repository.

Abusing the idea even further, because git itself is a very fast search tool with a built in ` git grep ` command, we can then use git itself on this separate tree to look up the needed information up quickly and parse the directory structure of the results to determine where changes have been made across different release branches. Even quicker tools like ` ripgrep ` can be used on these files as well.

Yes, using git to store a text version of a changelogs from a different git repository is a bit of “inception-style” logic, but it works surprisingly well and has been easy to work with and maintain over the years.

The layout of the tree is simple, there are 2 main directories for the git data:
- [` ids/`](https://git.sr.ht/~gregkh/linux-stable_commit_tree/tree/master/item/ids)that has one file per release, and that file contains the full list of SHA1 values in that release.
- [` releases/`](https://git.sr.ht/~gregkh/linux-stable_commit_tree/tree/master/item/releases)that has one subdirectory per stable release, containing the full changlog for that release in it.

With those two sets of files, the logic to look up where a git id has been backported to can be reduced to:
- Search all files in ` releases/` to see if a commit has been backported to a stable kernel release
- Search all files in ` ids/` to find what release this commit was in

As grep tools are very good, and the kernel caches the file information from the last query, looking up where a commit was backported to can be very quick. On a small laptop with the cache warmed up with the data, this can happen in about 0.3 seconds, good enough for simple queries when doing lookups for stable kernel development or other basic research work.

One other common task in stable kernel work is to attempt to determine if a specific commit has any later commits that fixed it. This is very useful when applying fixes to a branch as it is also good to apply the “fix for the fix” at the same time so that known fixes for regressions do not happen (and then sometimes also the “fix for the fix for the fix” and so on as sometimes resolving issues with crazy hardware can be difficult when doing debugging through email.)

To handle this, I added one more directory to this filesystem tree:
- [` changes/`](https://git.sr.ht/~gregkh/linux-stable_commit_tree/tree/master/item/changes)that has one subdirectory per release, and a file in that subdirectory for each commit in that release, named by the git id of the commit.

With the ` changes ` directory, you can then search for a ` Fixes:` line in a changelog message (a standard used in Linux kernel development) for any specific SHA1 value to see if a commit has been marked as fixing a specified commit.

As the ` changes ` directory is big, doing a search of it takes longer, averaging on my current laptop about 2 seconds per commit searched for. Ideally this can be threaded as this is a very CPU bound workload when the files are cached in memory, so the script ` find_fixes_in_queue ` will spawn a thread per cpu to do this work, greatly speeding up the overall effort for this occasional use.

This “abuse” of the filesystem as a database works really well for many environments where you can not install “non-standard” binary programs (i.e. some cloud systems or restricted environments) as all it needs is git and bash to work. It also can be used to search for “short” git ids, like is found in some commits or any other type of search string you wish to dig out of stable kernel changelogs.

Note, many times our kernel logs lie about the git id being backported, and do other very strange things, so “blindly grepping” doesn’t always work well to find all places where things have been backported. More on that below, but be aware that while this is a useful tool, it’s not always comprehensive, and can even be wrong in places. If you need to rely on this data for anything automated, I wouldn’t recommend using it.

I keep this git tree up to date as I rely on it for my stable kernel work, so feel free to use it as well.
## Getting smart about searching

The above mentioned “abuse of the filesystem as a database” has worked well for me for many years, as querying it was an occasional thing done. However, with the advent of us having to keep track of security bugs for CVEs, and needing to determine automatically, and very quickly, what commit was backported where, and to fix up all the places where we got backport ids wrong, I quickly realized early on in the CVE process that these shell scripts would just not cut it for real work.

So, I created the tool,[verhaal](https://git.sr.ht/~gregkh/verhaal). This tool takes the Linux kernel tree, parses all commit logs from all branches, and builds a sqlight database that you can use for lots of different types of lookups in a much faster, and more standardized way.

As releases happen only at a weekly basis, the tool can take more time to process the database (and now can incrementally update the database with new releases) and use that up-front processing time to provide a normalized database for lookups.

There are a few different tables in the database, the main one being called ` releases ` that looks like:

```
`(idTEXTPRIMARYKEYNOTNULL,releaseTEXTNOTNULL,mainlineINTEGER,mainline_idTEXT,revertsTEXT,fixesTEXT) `
```

these fields are:
- ` id `- git commit id for this commit
- ` release `- what kernel release this commit was in
- ` mainline `- 1 if this was a mainline release (i.e. Linus), or 0 if this was a stable release
- ` mainline_id `- if ` mainline ` is 0, this refers to the ` id ` of the mainline commit that this was cherry-picked from
- ` reverts `- if this commit reverts another commit, the ` id ` it reverts is filled in here
- ` fixes `- if this commit fixes other commits, those ` id ` values are listed here. If there are multiple fixes, they are separated by a space

There are also other tables in the database:
- ` ranges ` that express what “range” a release is (i.e. the 6.15 release is all commits after 6.14 through 6.15, and the 6.16.3 release is the commits from 6.13.2 through 6.13.3.) This is used to know what commits to look up in git when building the database as the tool must first walk the whole git tree to get a graph of all releases, in order to know what git commits to query for.
- ` releases ` that lists all releases in the git tree, and if that release is a “mainline” release or not
- ` fixes ` that has a set of “fixups” for when the original git commit id had something wrong in it and we need to manually override that information. This is imported from[a text file](https://git.sr.ht/~gregkh/verhaal/tree/main/item/fixes.txt)that I create with the help of other scripts every so often.

Using this tool, looking up “where was this commit backported to” now takes 0.01 seconds, a huge speed increase which really matters when needing to do lookups for this information at quantity, like we do for the CVE tracking.

Also, now that we have a database, looking up “was this commit fixed somewhere else” is a single sql query:

```
`SELECTid,releaseFROMcommitsWHEREmainline=1ANDfixesLIKE'SHA1';`
```

resulting in an almost instant result, making this part of a script that I now run much more frequently to ensure that we do not miss any “fixups for the fixes” when doing stable kernel releases.
## Difficulties in parsing our changelogs

Overall, the Linux kernel changelogs are pretty clean. The largest set of “mistakes” that we make is the use of invalid git ids in the “Fixes:” tag. With the addition of the ` fixes ` table, and some[“looser parsing”](https://git.sr.ht/~gregkh/verhaal/commit/03527a544f529ca1017f355cacc6596f1adcc721)logic, pretty much all of the changelogs can be correctly parsed now, which is pretty amazing given that this is usually all entered in manually by developers into their changelog texts. The majority of the work on ` verhaal ` was to figure out how to find the ranges of commits to parse, get things to go fast, and of course the traditional issue with C programs, “not leaking gobs of memory when running”. I started this tool before I really knew the Rust language, and if I had to do it over again, I would probably just use Rust instead of C, but overall, it’s a pretty tiny and simple tool to build a sqlite database that other tools can then query in many different ways that the original “abuse the filesystem” layout can not handle well, if at all.