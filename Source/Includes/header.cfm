<!---
################################################################################
#
# Filename:		header.cfm
#
# Description:	The page-level header
#
################################################################################
--->

<CFOUTPUT>
<!DOCTYPE HTML PUBLIC "#stPageDetails.DTPublicIdentifier#" "#stPageDetails.DTSystemIdentifier#">

<HTML>
<HEAD>
	<TITLE>#stPageDetails.Title#</TITLE>
	<META HTTP-EQUIV="Content-Type" CONTENT="#stPageDetails.ContentType#">
	<LINK REL="stylesheet" HREF="#stSiteDetails.BaseURL#/CSS/site.css" TYPE="text/css">
	<link rel="stylesheet" type="text/css" href="#stSiteDetails.BaseURL#/CSS/jscalendar.css" />

	<CFIF IsDefined("stPageDetails.CSS")>
		<LINK REL="stylesheet" HREF="#stSiteDetails.BaseURL#/CSS/#stPageDetails.CSS#" TYPE="text/css">
	</CFIF>

	<CFIF Len(Trim(stPageDetails.Keywords)) NEQ 0>
		<META NAME="Keywords" CONTENT="#stPageDetails.Keywords#">
	</CFIF>

	<CFIF Len(Trim(stPageDetails.Description)) NEQ 0>
		<META NAME="Description" CONTENT="#stPageDetails.Description#">
	</CFIF>

	<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript" SRC="#stSiteDetails.BaseURL#/JavaScript/menuBarStatus.js"></SCRIPT>
	<script type="text/javascript" src="#stSiteDetails.BaseURL#/JavaScript/jscalendar/calendar.js"></script>
	<script type="text/javascript" src="#stSiteDetails.BaseURL#/JavaScript/jscalendar/lang/calendar-en.js"></script>
	<script type="text/javascript" src="#stSiteDetails.BaseURL#/JavaScript/jscalendar/calendar-setup.js"></script>
</HEAD>

<BODY>

<!--- Banner Bar --->
<DIV CLASS="Banner">
	<SPAN ID="BannerLogo"><IMG SRC="#stSiteDetails.BaseURL#/images/logo_topleft.gif" WIDTH="302" HEIGHT="45"></SPAN>
	<SPAN ID="BannerTagline"><IMG SRC="#stSiteDetails.BaseURL#/images/head_topright.gif" WIDTH="395" HEIGHT="45"></SPAN>
</DIV>


<!--- Menu Bar --->
<DIV CLASS="MenuBar">
	<UL ID="MenuItems">
		<LI><A HREF="#stSiteDetails.BaseURL#/Transactions/" onMouseOver="setStatusText('One click access to all system functions');" onMouseOut="restoreStatusText();">Control Panel</A>
		<LI><A HREF="#stSiteDetails.BaseURL#/Transactions/import.cfm" onMouseOver="setStatusText('Import MS Excel Report from AMS 360');" onMouseOut="restoreStatusText();">Import from AMS 360</A>
		<LI><A HREF="#stSiteDetails.BaseURL#/Transactions/export.cfm" onMouseOver="setStatusText('Export data for transmission to AIG');" onMouseOut="restoreStatusText();">Data Export</A>
		<LI><A HREF="#stSiteDetails.BaseURL#/Transactions/archivedExports.cfm" onMouseOver="setStatusText('View past exports and transmissions');" onMouseOut="restoreStatusText();">Archived Exports</A>
	</UL>
	<SPAN ID="MenuBarStatus">
		&nbsp;
	</SPAN>
</DIV>


<DIV CLASS="Main">
</CFOUTPUT>

