<!---
################################################################################
#
# Filename:		transactionHistoryAction.cfm
#
# Description:	Transaction History Action page
#
################################################################################
--->

<!--- Initialize form variable values --->
<CFPARAM NAME="FORM.ClientID" DEFAULT="">
<CFPARAM NAME="FORM.LastName" DEFAULT="">


<!--- Validate submitted data --->
<CFINCLUDE TEMPLATE="ERR/ERR_transactionHistoryAction.cfm">


<!--- Display page or redirect user to new page --->
<CFIF cntErrors NEQ 0>
	<!--- Redisplay form --->
	<CFINCLUDE TEMPLATE="transactionHistory.cfm">
<CFELSE>
	<!--- Redirect to display screen --->
	<cflocation url="transactionHistoryDetails.cfm?ClientID=#FORM.ClientID#" addtoken="false">
</CFIF>

