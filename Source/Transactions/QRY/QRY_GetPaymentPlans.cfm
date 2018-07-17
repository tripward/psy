<!---
################################################################################
#
# Filename:		QRY_GetPaymentPlans.cfm
#
# Description:	Retrieves all Payment Plan Codes from the database
#
################################################################################
--->

<!--- Initialize variables --->


<!--- Query database --->
<cfquery name="GetPaymentPlans" datasource="#stSiteDetails.DataSource#">
	SELECT
		PaymentPlanID,
		PaymentPlanCode,
		PaymentPlan
	FROM
		aig2_xPaymentPlan
</cfquery>

