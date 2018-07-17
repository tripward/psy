<!---
################################################################################
#
# Filename:		QRY_GetStateSurcharge.cfm
#
# Description:	Retrieves specified state surcharges from the database
#
################################################################################
--->

<cfparam name="variables.surcharge" type="string" />


<!--- Query database for state surcharges --->
<cfquery name="GetStateSurcharge" datasource="#stSiteDetails.DataSource#">
	SELECT
		StateID,
		SurchargeID,
		Surcharge
	FROM
		aig2_Surcharge
	WHERE
		(
			EffectiveDate IS NULL
			OR EffectiveDate <= <cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(Now(), "mm/dd/yyyy")#">
		)
		AND
		(
			ExpirationDate IS NULL
			OR ExpirationDate >= <cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(Now(), "mm/dd/yyyy")#">
		)
		AND Surcharge = <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.surcharge#">
</cfquery>

