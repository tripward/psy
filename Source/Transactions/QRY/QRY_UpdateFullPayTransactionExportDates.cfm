<!---
################################################################################
#
# Filename:		QRY_UpdateFullPayTransactionExportDates.cfm
#
# Description:	Updates transactions to set ExportDateTime in the database
#
################################################################################
--->

<!--- Check for required variables --->
<cfparam name="variables.affectedFullPayPolicies" default="">


<!--- Query database for transaction records --->
<cfquery name="UpdateFullPayTransactionExportDates" datasource="#stSiteDetails.DataSource#">
	UPDATE
		aig2_Transaction
	SET
		InstallmentPaidNum = InstallmentPaidNum + 1,
		AccountsCurrentExportDateTime = <cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(Now(), 'mm/dd/yyyy')#">
	WHERE
		TransactionID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#variables.affectedFullPayPolicies#" list="true">)
</cfquery>

