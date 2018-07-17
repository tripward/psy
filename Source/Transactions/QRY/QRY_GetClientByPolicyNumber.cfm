<!---
################################################################################
#
# Filename:		QRY_GetClientByPolicyNumber.cfm
#
# Description:	Retrieves client by Name from the database
#
################################################################################
--->

<!--- Check for required variables --->
<cfparam name="form.PolicyNumber" type="String">


<!--- Query database for client record --->
<cfquery name="GetClientByPolicyNumber" datasource="#stSiteDetails.DataSource#">
	SELECT
		Clients.[Client ##] AS ClientID,
		Clients.[Last Name] AS LastName,
		Clients.[First Name] AS FirstName,
		Clients.[Business Name] AS BusinessName
	FROM
		Clients
		INNER JOIN Malprac
			ON Clients.[Client ##] = Malprac.[Client ##]
	WHERE
		Malprac.[Pol## number] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.PolicyNumber#">
</cfquery>