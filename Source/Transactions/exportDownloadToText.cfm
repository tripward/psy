<!---
################################################################################
#
# Filename:		exportDownloadToText.cfm
#
# Description:	Download export as text
#
################################################################################
--->

<CFSETTING ENABLECFOUTPUTONLY="Yes" SHOWDEBUGOUTPUT="No">


<!--- Get Title Lookup data --->
<CFSET VARIABLES.ExportTypeID = FORM.ExportTypeID>
<CFINCLUDE TEMPLATE="QRY/QRY_GetExportType.cfm">

<CFSET VARIABLES.TransactionCodeID = FORM.TransactionCodeID>
<CFINCLUDE TEMPLATE="QRY/QRY_GetTransactionCodes.cfm">


<!--- Determine transaction types --->
<CFSET VARIABLES.Codes = "">

<CFLOOP FROM="1" TO="#GetTransactionCodes.RecordCount#" INDEX="cnt">
	<CFSET VARIABLES.Codes = VARIABLES.Codes & GetToken(GetTransactionCodes.Transaction[cnt], 1, ",")>

	<CFIF cnt NEQ GetTransactionCodes.RecordCount>
		<CFSET VARIABLES.Codes = VARIABLES.Codes & ", ">
	</CFIF>
</CFLOOP>


<!--- Update database --->
<CFTRANSACTION>
	<!--- Transfer FORM variables to local scope --->
	<CFIF FORM.RangeInd EQ 1>
		<CFSET VARIABLES.RangeStartDate = FORM.RangeStartDate>
		<CFSET VARIABLES.RangeEndDate = FORM.RangeEndDate>
	</CFIF>
	<CFSET VARIABLES.TransactionCodeID = FORM.TransactionCodeID>
	<CFSET VARIABLES.ExportTypeID = FORM.ExportTypeID>
	<CFSET VARIABLES.PositiveOnlyInd = FORM.PositiveOnlyInd>

	<!--- Get Transactions --->
	<CFINCLUDE TEMPLATE="QRY/QRY_GetTransactions.cfm">

	<!--- Don't change data if downloading from archive --->
	<cfif (NOT IsDefined("form.archivedInd")) OR (form.archivedInd NEQ 1)>
		<!--- Set ExportDateTime for exported transactions --->
		<cfif variables.ExportTypeID EQ 1>
			<!--- Premium Coding --->
			<cfinclude template="QRY/QRY_UpdateTransactionExportDates.cfm">
		<cfelse>
			<!--- Accounts Current --->
			<!--- Update full pay policies --->
			<cfif (IsDefined("variables.affectedFullPayPolicies")) AND (Len(Trim(variables.affectedFullPayPolicies)) NEQ 0)>
				<cfinclude template="QRY/QRY_UpdateFullPayTransactionExportDates.cfm">
			</cfif>

			<!--- Update installment policies --->
			<cfif (IsDefined("variables.affectedInstallmentPolicies")) AND (Len(Trim(variables.affectedInstallmentPolicies)) NEQ 0)>
				<cfinclude template="QRY/QRY_UpdateInstallmentsPaidCounts.cfm">
			</cfif>
		</cfif>

		<!--- Archive export --->
		<CFSET VARIABLES.NumTransactions = GetTransactions.RecordCount>
		<CFINCLUDE TEMPLATE="QRY/QRY_AddExport.cfm">

		<!--- Asociate transactions with export --->
		<CFLOOP QUERY="GetTransactions">
			<CFSET VARIABLES.TransactionID = GetTransactions.TransactionID>
			<CFSET VARIABLES.ExportID = AddExport.ThisID>
			<CFINCLUDE TEMPLATE="QRY/QRY_AddTransactionExport.cfm">
		</CFLOOP>
	</cfif>
</CFTRANSACTION>


<!--- Determine filename --->
<CFIF VARIABLES.ExportTypeID EQ 2>
	<CFSET VARIABLES.FileName = "ac_PSY_" & DateFormat(Now(), "yyyymmdd") & ".txt">
<CFELSE>
	<CFSET VARIABLES.FileName = "pr_PSY_" & DateFormat(Now(), "yyyymmdd") & ".txt">
</CFIF>


<!--- Download as text --->
<CFHEADER NAME="content-disposition" VALUE="attachment; filename=#VARIABLES.FileName#">
<CFCONTENT TYPE="text/plain">
<CFOUTPUT>#VARIABLES.BuildExport#</CFOUTPUT>


<CFSETTING ENABLECFOUTPUTONLY="Yes">

