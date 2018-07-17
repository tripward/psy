<!---
################################################################################
#
# Filename:		QRY_UpdateInstallmentsPaidCounts.cfm
#
# Description:	Updates InstallmentPaidNum
#
################################################################################
--->

<!--- Check for required variables --->
<cfparam name="variables.affectedInstallmentPolicies" default="">


<!--- Query database for transaction records --->
<cfquery name="UpdateInstallmentsPaidCounts" datasource="#stSiteDetails.DataSource#">
	UPDATE
		aig2_Transaction
	SET
		InstallmentPaidNum = InstallmentPaidNum + 1
	WHERE
		TransactionID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#variables.affectedInstallmentPolicies#" list="true">)
</cfquery>

