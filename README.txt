SFX EBSCO_HOST::ebsco_hbr parser
A target parser to be used with SFX OpenURL link resolver

BACKGROUND: There is a problem linking with SFX to the 500 restricted articles in
Harvard Business Review.  It seems that HBR is forcing EBSCO to block SFX
links to these articles because EBSCO is using persistent linking behind
the scenes to resolve the SFX OpenURLs. EBSCO has thus far refused to lift
the restriction on "persistent links".

WORKAROUND: The HBR parser sends the article title and journal title to EBSCO as a
search. E.g.,

http://search.ebscohost.com/login.aspx?direct=true&db=bth&bquery=(TI+(Leading+Change%3a+Why+Transformation+Efforts+Fail))+AND+(SO+(Harvard+business+review))&type=1&site=ehost-live&scope=site

METHOD:

1) Save the target parser file ebsco_hbr.pm in the directory /exlibris/sfx_ver/sfx4_1/[INSTANCE]/lib/Parsers/TargetParser/EBSCO_HOST
2) Copy the Business Source [whatever you have] Target. The database code is set in the Parse Param field.
3) Change the Global Parser to EBSCO_HOST::ebsco_hbr
4) Activate the getFullTxt service, and then only the HBR portfolio.

ISSUES:

1) Links are created for all articles in the Harvard Business Review, not just the 500 restricted articles.
2) This method will produce less than useful results for titles with a generic title, such as "Editorial".
