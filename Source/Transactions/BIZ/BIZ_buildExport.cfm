<!---
################################################################################
#
# Filename:		BIZ_buildExport.cfm
#
# Description:	Builds an AIG export from the GetTransactions QRS
#
################################################################################
--->

<!--- Initialize variables --->
<CFSET VARIABLES.BuildExport = "">


<!--- Determine export type --->
<CFINCLUDE TEMPLATE="../QRY/QRY_GetExportType.cfm">


<!--- Determine Export Date --->
<CFIF IsDefined("VARIABLES.RangeEndDate") AND IsDate(VARIABLES.RangeEndDate)>
	<CFSET VARIABLES.ExportDate = "#Month(VARIABLES.RangeEndDate)#/#DaysInMonth(VARIABLES.RangeEndDate)#/#Year(VARIABLES.RangeEndDate)#">
<CFELSE>
	<CFSET VARIABLES.ExportDate = "#Month(Now())#/#DaysInMonth(Now())#/#Year(Now())#">
</CFIF>


<!--- Determine type of export to build --->
<CFSET VARIABLES.t_TransactionCodeID = VARIABLES.TransactionCodeID>
<CFSWITCH EXPRESSION="#GetExportType.ExportType#">
	<CFCASE VALUE="Premium Coding">
		<!--- Query database --->
		<CFINCLUDE TEMPLATE="../QRY/QRY_GetTransactions.cfm">

		<!--- Build export --->
		<CFINCLUDE TEMPLATE="BIZ_buildPremiumCodingExport.cfm">
		<CFSET VARIABLES.TotalPremium = totalGrossPremium>
	</CFCASE>

	<CFCASE VALUE="Accounts Current">
		<!--- Query database --->
		<CFINCLUDE TEMPLATE="../QRY/QRY_GetTransactionsPreviousTwelveMonths.cfm">
		<cfset GetTransactions = GetTransactionsPreviousTwelveMonths>

		<!--- Build export --->
		<CFINCLUDE TEMPLATE="BIZ_buildAccountsCurrentExport.cfm">
		<CFSET VARIABLES.TotalPremium = grandTotalGrossPremium>
	</CFCASE>
</CFSWITCH>
<CFSET VARIABLES.TransactionCodeID = VARIABLES.t_TransactionCodeID>

