<!---
################################################################################
#
# Filename:		config.cfm
#
# Description:	Configuration file
#
################################################################################
--->

<!--- Create Site Details structure and initialize with defaults --->
<cfset stSiteDetails = StructNew()>
<cfset stSiteDetails.BaseURL = "/CIS_Psychiatry">
<cfset stSiteDetails.BasePath = "C:\CIS_Psychiatry\Source">
<cfset stSiteDetails.DataSource = "CIS_Psychiatry">
<cfset stSiteDetails.DateMask = "MMMM d, yyyy">
<cfset stSiteDetails.DateSpanMask.StartDate = "MMMM d-">
<cfset stSiteDetails.DateSpanMask.EndDate = "d, yyyy">
<cfset stSiteDetails.TimeMask = "h:MM tt">


<!--- Create Page Details structure and initialize with defaults --->
<cfset stPageDetails = StructNew()>
<cfset stPageDetails.Title = "CIS Psychiatry: ">
<cfset stPageDetails.Keywords = "">
<cfset stPageDetails.Description = "">
<cfset stPageDetails.DTPublicIdentifier = "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfset stPageDetails.DTSystemIdentifier = "http://www.w3.org/TR/html4/loose.dtd">
<cfset stPageDetails.ContentType = "text/html; charset=iso-8859-1">
<cfset stPageDetails.BreadCrumb = "">


<!--- Define System Constants --->
<cfset stSystemConstants = StructNew()>
<cfset stSystemConstants.acFeedSequenceNumber = "416">
<cfset stSystemConstants.acPolicySymbol = "CNM">
<cfset stSystemConstants.acBranchNumber = 34>

<cfset stSystemConstants.pcFeedSequenceNumber = "415">
<cfset stSystemConstants.pcPolicySymbol = "CIS">	<!--- AIC = "Pri CM Anesthesiologist"; AGC = "Pri CM Group Anesthesiologist" --->
<cfset stSystemConstants.pcBranchNumber = 57>

<cfset stSystemConstants.adjustmentIndicator = "">
<cfset stSystemConstants.agencyBillIndicator = "A">
<cfset stSystemConstants.aicoIndicator = "">
<cfset stSystemConstants.aigrmContractNumber = "">
<cfset stSystemConstants.aiStartSubmissionNumber = 0>
<cfset stSystemConstants.ascoCompanyNumber = 29>
<cfset stSystemConstants.biDeductibleCode = "">
<cfset stSystemConstants.biLimitCode = "">
<cfset stSystemConstants.commissionRate = 23>
<cfset stSystemConstants.coverageMajorClass = "659">
<cfset stSystemConstants.coverageNumber = "001">
<cfset stSystemConstants.coverageSymbol = "CNM">
<cfset stSystemConstants.defaultInsuranceCompanyID = 029>
<cfset stSystemConstants.divisionCode = 066>
<cfset stSystemConstants.eStartSubmissionNumber = 0>
<cfset stSystemConstants.exportAttachmentFileName = "#stSiteDetails.BasePath#\Temp\">
<cfset stSystemConstants.exportToAddress = "mlowenstein@cisinsurance.com">
<cfset stSystemConstants.exportCcAddress = "">
<cfset stSystemConstants.exportFromAddress = "Elan Hichenberg <elan@cisinsurance.com>">
<cfset stSystemConstants.exposureAmount = "0">
<cfset stSystemConstants.exposureBase = "">
<cfset stSystemConstants.insuranceCompanyID = 29>
<cfset stSystemConstants.limitedCoding = 1>
<cfset stSystemConstants.lineOfBusiness = "">
<cfset stSystemConstants.locationNumber = "001">
<cfset stSystemConstants.majorClass = "0659">
<cfset stSystemConstants.masterCertAndDecNumber = "00000000000">
<cfset stSystemConstants.mgaTransaction = "Y">
<cfset stSystemConstants.njSurplusLinesLicenseNumber = "G069A">
<cfset stSystemConstants.policyFormCode = "C">
<cfset stSystemConstants.policyType = "9U">
<cfset stSystemConstants.premiumRecordType = "P">
<cfset stSystemConstants.previousCertNumber = "">
<cfset stSystemConstants.producerNumber = 54485>
<cfset stSystemConstants.rateCommission = "">
<cfset stSystemConstants.rateDeductible = "">
<cfset stSystemConstants.rateExpense = "">
<cfset stSystemConstants.rateExperience = "">
<cfset stSystemConstants.ratePackage = "">
<cfset stSystemConstants.rateSchedule = "">
<cfset stSystemConstants.statPlanNumber = "29">
<cfset stSystemConstants.surplusLinesAgentsAddress = "11301 Amherst Avenue, Suite 201">
<cfset stSystemConstants.surplusLinesAgentsCity = "Silver Spring">
<cfset stSystemConstants.surplusLinesAgentsName = "Israel Teitelbaum">
<cfset stSystemConstants.surplusLinesAgentsState = "MD">
<cfset stSystemConstants.tailDate = "00000000">
<cfset stSystemConstants.terrorismTypeCode = 2>


<!--- Define CrLf --->
<cfset CrLf = Chr(13) & Chr(10)>
