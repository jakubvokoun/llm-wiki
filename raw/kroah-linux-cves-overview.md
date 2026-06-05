# Linux CVEs, more than you ever wanted to know

Posted on December 8, 2025 | Greg K-H

It's been almost 2 full years since [Linux became a CNA (Certificate Numbering Authority)](http://www.kroah.com/log/blog/2024/02/13/linux-is-a-cna/) which meant that we (i.e. the kernel.org community) are now responsible for issuing all CVEs for the Linux kernel. During this time, we've become one of the largest creators of CVEs by quantity, going from nothing to number 3 in 2024 to number 1 in 2025. Naturally, this has caused some questions about how we are both doing all of this work, and how people can keep track of it.

I've given a number of talks over the past years about this, starting with the [Open Source security podcast right after we became a CNA](https://opensourcesecurity.io/2024/02/25/episode-417-linux-kernel-security-with-greg-k-h/) and then the [Kernel Recipes 2024 talk, "CVEs are alive, but do not panic"](https://kernel-recipes.org/en/2024/cves-are-alive-but-no-not-panic/) and then a talk at [OSS Hong Kong 2024 about the same topic with updated numbers](https://www.youtube.com/watch?v=at-uDXbX-18) and later a talk at [OSS Japan 2024 with more info about the same topic](https://www.youtube.com/watch?v=KumwRn1BA6s) and finally for 2024 a talk with more detail that I can't find the online version.

In 2025 I did lots of work on the [CRA](https://digital-strategy.ec.europa.eu/en/policies/cyber-resilience-act) so most of my [speaking over this year has been about that topic](https://kernel-recipes.org/en/2025/schedule/the-cra-and-what-it-means-for-us/), but the CVE assignment work continued on, evolving to meet many of the issues we had in our first year of being a CNA. As that work is not part of the Linux kernel source directly, it's not all that visible to the normal development process, except for the constant feed on the [linux-cve-announce mailing list](https://lore.kernel.org/linux-cve-announce/).

I figured it was time to write down how this is all now working, as well a bunch of background information about how Linux is developed that is relevant for how we do CVE reporting (i.e. almost all non-open-source-groups don't seem to know how to grasp our versioning scheme.)

There is a [in-kernel document](https://www.kernel.org/doc/html/latest/process/cve.html) that describes how CVEs can be asked for from the kernel community, as well as a basic summary of how CVEs are automatically assigned. But as we are an open community, it's good to go into more detail as to how all of us do this work, explaining how our tools have evolved over time and how they work, why some things are the way they are for our releases, as well as document a way that people can track CVE assignments on their own in a format that is, in my opinion, much simpler than attempting to rely on the CVE json format (and don't get me started on NVD…)

So here's a series of posts going into all of this, hopefully providing more information than you ever wanted to know, which might be useful for other open source projects as they start to run into many of the same issues we have already dealt with (i.e. how to handle reports at scale):

* [Linux kernel versions](http://www.kroah.com/log/blog/2025/12/09/linux-kernel-version-numbers/), how the Linux kernel releases are numbered.
* [Tracking kernel commits across branches](http://www.kroah.com/log/blog/2025/12/15/tracking-kernel-commits-across-branches/), how to keep track of Linux kernel commits as they move from the main release branch into the different stable releases in an automated way.
* [Linux kernel security work](http://www.kroah.com/log/blog/2026/01/02/linux-kernel-security-work/) how the Linux kernel security team works to fix reported security bugs.
* [Linux CVE assignment process](http://www.kroah.com/log/blog/2026/02/16/linux-cve-assignment-process/), how the Linux CVE team processes bugs and classifies them as CVEs.
* Linux CVE tools, how a kernel commit is turned into a CVE entry automatically and kept up to date over time (future post).
