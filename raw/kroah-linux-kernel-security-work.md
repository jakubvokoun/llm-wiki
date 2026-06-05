# Linux kernel security work

Posted on January 2, 2026 | Greg K-H

Lots of the CVE world seems to focus on "security bugs" but I've found that it
is not all that well known exactly how the Linux kernel security process works.
I gave a
[talk about this back in 2023](https://www.linuxfoundation.org/webinars/demystifying-the-linux-kernel-security-process)
and at other conferences since then, attempting to explain how it works, but I
also thought it would be good to explain this all in writing as it is required
to know this when trying to understand how the Linux kernel CNA issues CVEs.

This is a post in the series about the Linux kernel CVE release process:

* [Linux kernel versions](http://www.kroah.com/log/blog/2025/12/09/linux-kernel-version-numbers/),
  how the Linux kernel releases are numbered.
* [Tracking kernel commits across branches](http://www.kroah.com/log/blog/2025/12/15/tracking-kernel-commits-across-branches/),
  how to keep track of Linux kernel commits as they move from the main release
  branch into the different stable releases in an automated way.
* Linux kernel security work (this post),
  how the Linux kernel security team works to fix reported security bugs.
* [Linux CVE assignment process](http://www.kroah.com/log/blog/2026/02/16/linux-cve-assignment-process/),
  how the Linux CVE team processes bugs and classifies them as CVEs.
* Linux CVE tools,
  how a kernel commit is turned into a CVE entry automatically and kept up to
  date over time (future post).

## tl;dr

Summary up front for those not wanting to read a wall of text:

* The Linux kernel [security team](https://www.kernel.org/doc/html/latest/process/security-bugs.html)
  work to fix reported issues as quickly as possible and get the fixes merged
  to public trees, and do not do any announcements anywhere.
* The Linux kernel security team and the
  [CVE team](https://www.kernel.org/doc/html/latest/process/cve.html)
  are different groups of people, all of whom do this work on their own
  recognition, not associated with any company.
* Only send plain text emails to the kernel security team.
* Do not email the kernel security team and expect to get a CVE assigned.

## Reactive, not proactive, security work

The [Linux kernel security team](https://www.kernel.org/doc/html/latest/process/security-bugs.html)
is group of Linux kernel developers who are responsible for triaging potential
security bugs that are reported to them, and get them fixed as soon as
possible. They do this work as "reactive" for security issues, independent of
the great "proactive" kernel security work that the [Kernel Self-protection
project](https://kspp.github.io/) has been
[doing for the past 10+ years.](https://docs.kernel.org/security/self-protection.html)

## Kernel security team

As can be seen in the [in-kernel documentation](https://www.kernel.org/doc/html/latest/process/security-bugs.html)
to contact the security team, just email the address in that document the
potential issue that you have found, without using HTML or any binary
attachments, and the developers there will take the report and usually ask
questions and work to resolve the issue if it turns out to actually be a real
security issue. Many issues reported are not, and so the reporter is told to
send their bug report to the respective mailing list and work on it with the
developers there, in public.

When reporting a bug, just send a simple, plain text email to the security
alias. Do not send an email that contains a binary attachment as opening
unsolicited binary files is not anything anyone should be doing. Also do not
use markdown formatting, just plain text. Also, no encryption is needed, as it
will not work due to the email alias handling (i.e. one address to many
individuals.) If you are forced to use encryption to report security problems,
please reconsider this policy as it feels counterproductive (UK government,
this means you…)

The members of the security team contain a handful of core kernel developers
that have experience dealing with security bugs, and represent different major
subsystems of the kernel. They do this work as individuals, and specifically
can NOT tell their employer, or anyone else, anything that is discussed on the
security alias before it is resolved. This arrangement has allowed the kernel
security team to remain independent and continue to operate across the
different governments that the members operate in, and it looks to become the
normal way project security teams work with the advent of the European Union's
new CRA law coming into affect which places requirements on response time of
companies that receive notice of potential security issues in their projects.

### How the fix happens

The way the security team works is when a bug is reported, if the members do
not have experience in that specific subsystem, they drag the maintainers of
that subsystem into the email chain, and work to get the bug resolved. If a
subsystem has a continued number of bugs reported over time, the maintainer can
be "asked" if they wish to join the alias to help remove the additional "hop"
of bug triage happening. This is what has caused the alias members to
naturally grow over time to end up representing the major portions of the
kernel with the most issues.

Ideally the bug reporter also provides a working fix for the issue, allowing
them to get the proper credit for the fix but of course that does not always
happen. If no fix is provided, the developers involve work to resolve the bug
as soon as they can, and when they agree it is resolved, get it merged into the
main kernel branch and the stable kernel releases as soon as possible.

### No embargoes

As the documentation states, no embargoes longer than 7 days are allowed, once
a working fix is made, as there's no real reason to hold off on getting a fix
merged at that time. Only very few changes ever have any embargo at all, as
it's more bother than it is worth.

Once the bug is fixed in the kernel trees, the developer's work is finished,
and it is up to the reporter if they wish to "announce" a bugfix or not. The
kernel security team on their own do not do any reporting or external
communication at all. Only later, if the fix is warranted to justify a CVE
being assigned, is the commit announced as a security fix, but that work is
done by the kernel CVE team, NOT the kernel security team.

More about how the kernel CVE team works in a later post in this series…

## A bug is a bug is a bug

This "do not announce anything" policy has been present in the kernel security
team since the very beginning, and as you can imagine, has caused much
"disagreement" by those outside of the kernel community. This came up soon
after the kernel security team was established in a
[2008 email thread with Linus](https://lore.kernel.org/lkml/alpine.LFD.1.10.0807151620450.2867%40woody.linux-foundation.org/):

```
  On Wed, 16 Jul 2008, pageexec@freemail.hu wrote:
  >
  > you should check out the last few -stable releases then and see how
  > the announcement doesn't ever mention the word 'security' while fixing
  > security bugs

  Umm. What part of "they are just normal bugs" did you have issues with?
  I expressly told you that security bugs should not be marked as such,
  because bugs are bugs.

  > in other words, it's all the more reason to have the commit say it's
  > fixing a security issue.

  No.

  > > I'm just saying that why mark things, when the marking have no meaning?
  > > People who believe in them are just _wrong_.
  >
  > what is wrong in particular?

  You have two cases:

  - people think the marking is somehow trustworthy.

    People are WRONG, and are misled by the partial markings, thinking that
    unmarked bugfixes are "less important". They aren't.

  - People don't think it matters

    People are right, and the marking is pointless.
    In either case it's just stupid to mark them. I don't want to do it,
    because I don't want to perpetuate the myth of "security fixes" as a
    separate thing from "plain regular bug fixes".

    They're all fixes. They're all important. As are new features, for that
    matter.

  > when you know that you're about to commit a patch that fixes a security
  > bug, why is it wrong to say so in the commit?

  It's pointless and wrong because it makes people think that other bugs
  aren't potential security fixes.

  What was unclear about that?

  Linus
```

The [whole email
thread](https://lore.kernel.org/lkml/20080703035807.GA8190%40kroah.com/) is worth
reading.

### No one knows how you use open source

The primary reason why the kernel does not do any security announcements is
that almost any bugfix at the level of an operating system kernel can be a
"security issue" given the issues involved (memory leaks, denial of service,
information leaks, etc.) Also, given that Linux is open source, the developers
involved in fixing problems do NOT know how Linux is being used. A simple
bugfix for a minor thing for one user could be a major system vulnerability fix
for a different user, all depending on how Linux is being used.
[Ben Hawkes](https://blog.isosceles.com/author/ben/)
said it best in a wonderful essay about
["What is a good Linux kernel bug"](https://blog.isosceles.com/what-is-a-good-linux-kernel-bug/):

> "It's hard to capture the fact that a bug can be
> super serious in one type of deployment, somewhat
> important in another, or no big deal at all – and that
> the bug can be all of this at the same time.
> Vulnerability remediation is hard."
> – Ben Hawkes

Always remember, kernel developers:

* do not know your use case.
* do not know what code you use.
* do not want to know any of this.

So, overall, the kernel security bug policy can be boiled down to:

* Fix known bugs as soon as possible.
* Get releases out to users as quickly as possible.

For those that are always worried "what if a bugfix causes problems", they
should remember that a fix for a known bug is better than the potential of a
fix causing a future problem as future problems, when found, will be fixed
then. You never want to have "known bugfixes" not resolved on your system at
any time. So much so that recent laws will soon be preventing you that being
allowed for many countries.

## Hardware security issues

As history has shown us with
[Spectre](https://en.wikipedia.org/wiki/Spectre_%28security_vulnerability%29)
and
[Meltdown](https://en.wikipedia.org/wiki/Meltdown_%28security_vulnerability%29),
this "no embargo" policy does not always work well when working with problems
that cross operating systems and hardware platforms, possibly requiring
firmware or microcode updates. Because of this, the kernel developers have
been forced to come up with a
["Hardware Security policy"](https://www.kernel.org/doc/html/latest/process/embargoed-hardware-issues.html)
to handle these types of issues.

This different workflow involves the creation of a special encrypted and
restricted email list containing just the needed kernel and hardware developers
that are required to get the problem solved. With this process, embargoes are
grumpily tolerated for now. Many different hardware bugs have been resolved in
Linux over the years through this process, but as a participant in some of
these efforts, it is clunky, awkward, and often times extremely slow. The
kernel developers involved really do not like this process, and hopefully this
will be phased out over time as many hardware issues have been resolved in the
past year without having to get this special process involved at all.

Also, due to the CRA timelines, long embargo times will probably not even be
possible for hardware companies to handle. How that is going to interact with
microcode and firmware updates in the next few years is going to be an
"interesting" thing to watch evolve.

## How this all started

Way back in 2005, there was not any "official" way to contact anyone about
kernel security bugs. It was just an ad-hock group of people that developers
"knew" they could email problems to. That obviously did not really scale, and
was not helpful for anyone who did not know how the kernel developers worked.
This came to a head in 2005 with
[this email from Steve Bergman](https://lore.kernel.org/lkml/41E2B181.3060009%40rueb.com/):

```
From: Steve Bergman <steve@rueb.com>
To: linux-kernel@vger.kernel.org
Subject: Proper procedure for reporting possible security vulnerabilities?
Date: Mon, 10 Jan 2005 10:46:57 -0600

There seems to be some confusion in certain quarters as to the proper
procedure for reporting possible kernel security issues.

REPORTING-BUGS says send bug reports to the maintainer of that area of
the kernel. However, what about areas for which a maintainer is not
listed? (e.g. VM) It seems that some take that to mean send it
directly to Linus and if you don't hear something back quickly, release
an exploit to the wild.

So what is the preferred procedure and is it documented somewhere?
Should it be made more prominent?

Thanks for any information,
Steve Bergman
```

That naturally kicked off a bit of discussion, so 36 emails later, the idea of
a central email alias that could handle reported security issues was decided on
and a few months later, was
[written up by Chris Wright](https://lore.kernel.org/all/20050309090550.GW28536%40shell0.pdx.osdl.net/):

```
From: Chris Wright <chrisw@osdl.org>
To: torvalds@osdl.org
Cc: akpm@osdl.org, alan@lxorguk.ukuu.org.uk,
    marcelo.tosatti@cyclades.com, linux-kernel@vger.kernel.org
Subject: [PATCH] Security contact info
Date: Wed, 9 Mar 2005 01:05:50 -0800

Add security contact info and relevant documentation.

Signed-off-by: Chris Wright <chrisw@osdl.org>

 MAINTAINERS                |    5 +++++
 REPORTING-BUGS             |    4 ++++
 Documentation/SecurityBugs |   38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+)
```

## No security announcements

As stated earlier, the kernel security team does not do any sort of
announcements at all, or any public statements anywhere. They are also not
responsible for assigning CVE ids to any kernel bugfixes, that is a different
team's responsibility that happens after kernel bugfixes are in public kernel
releases, and almost never before.

Because they do not do any announcements, there is also no "early announcement"
list, despite many companies constantly asking to "join the security
pre-announcement security list" requests we get.

The primary reason there is no pre-announcement list is overall they should
always be considered public and contain leaks. Otherwise, why would your
government allow them to exist? Unless the list is for a project that is not
really used by anyone…
