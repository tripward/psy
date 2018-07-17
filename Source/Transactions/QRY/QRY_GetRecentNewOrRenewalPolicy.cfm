<!---
################################################################################
#
# Filename:		QRY_GetRecentNewOrRenewalPolicy.cfm
#
# Description:	Gets most recent new or renewal transaction for the specified PolicyNyumber
#
################################################################################
--->

<!--- Check for required variables --->
<cfparam name="variables.PolicyNumber" type="numeric">


<!--- Query database for transaction records --->
<cfquery name="GetRecentNewOrRenewalPolicy" datasource="#stSiteDetails.DataSource#">
	SELECT
		TOP 1
		TransactionID,
		TransactionCodeID,
		PolicyNumber,
		PolicyEffectiveDate,
		PolicyExpirationDate,
		TransactionEffectiveDate,
		TransactionExpirationDate,
		FirstName,
		MiddleInitial,
		LastName,
		BusinessName
	FROM
		aig2_Transaction
	WHERE
		TransactionCodeID IN (1,2)
		AND PolicyNumber = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.PolicyNumber#">
	ORDER BY
		PolicyEffectiveDate DESC
</CFQUERY>

