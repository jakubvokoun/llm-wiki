# Customization — OpenSCAP Security Policies

## Customization — also called tailoring — allows you to make small adjustments to security policies

## What is customization?

Customization is a process of adjusting SCAP security policy for your needs. These adjustments can be selecting or un-selecting a rule, changing some rule's value – minimum password length for example – or even changing selection of an entire group of rules. Customization can be done to make a security policy stricter – perhaps requiring even longer passwords – or more lenient – for example allowing root login over ssh.

The point of customization is to store the customizations separately from the original policy so that the original can be updated with bugfixes and new rules without overwriting your changes. You can also tailor signed XCCDF without making any of the signatures invalid.

### How to customize content with SCAP Workbench

SCAP Workbench is the tool of choice for security policy customization. Any profile of any content opened in SCAP Workbench can be customized by clicking the **Customize** button. Doing so will create a new profile that inherits everything from the original profile. This is an important concept of customization, profiles are extended, not changed in-place. Each XCCDF Rule and Group can be selected or un-selected and each XCCDF Value can be changed. [Read more about SCAP Workbench](/tools/scap-workbench).

### Saving customization, deployment

After you are finished with the customization and have tested them on a few machines it's time to save the customization. SCAP Workbench allows you to save it to a file in XCCDF Customization format. It is a XML file containing just the new XCCDF profiles. The original content is still needed for evaluation.

This file can be used in many OpenSCAP projects – the oscap tool, SCAP Workbench, OpenSCAP Daemon, Spacewalk and Foreman.

### Where to go from here?

**This document merely describes what customization is and only goes into the basics.**

You can start with the tutorial [Customizing SCAP Security Guide for your use-case](/resources/documentation/customizing-scap-security-guide-for-your-use-case/).

If you want a more complete picture of how Customization fits into SCAP evaluation, read [Evaluate remote machine for USGCB compliance](/resources/documentation/evaluate-remote-machine-for-usgcb-compliance-with-scap-workbench/) and the [SCAP Workbench 1.1 user manual](http://static.open-scap.org/scap-workbench-1.1/).
