<!---
################################################################################
#
# Filename:		Application.cfm
#
# Description:	Application Definition file
#
################################################################################
--->

<!--- Initialize and name application --->
<cfapplication name="#Right(Replace(GetDirectoryFromPath(GetCurrentTemplatePath()), "\", "_", "ALL"), 64)#"
	sessionmanagement="Yes"
	sessiontimeout="#CreateTimeSpan(0, 1, 0, 0)#"
	applicationtimeout="#CreateTimeSpan(0, 1, 0, 0)#">


<!--- Include configuration file --->
<cfinclude template="config.cfm">


<!--- Include UDF Library --->
<cfinclude template="Includes/UDF_Library.cfm">

