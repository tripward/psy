<!---
################################################################################
#
# Filename:		BIZ_buildPremiumCodingExport.cfm
#
# Description:	Builds a Premium Coding export from the GetTransactions QRS
#
################################################################################
--->

<!--- Initialize variables --->
<CFSET VARIABLES.BuildExport = "">
<CFSET totalGrossPremium = 0>
<CFSET totalSurcharge = 0>
<CFSET totalKyCollectionFee = 0>
<CFSET totalKyMunicipalTax = 0>






<!--- Build transaction time stamp --->
<CFSET VARIABLES.generationTimeStamp = Year(Now()) & UDF_padValue(DayOfYear(Now()), "0", "RIGHT", 3) & TimeFormat(Now(), "hhmmss")>


<!--- Build Data Records --->
<CFLOOP QUERY="GetTransactions">
	<!--- Build Insured Name - "Last, First MI" or "Business Name as dba Business Name" --->
	<cfif ( (Len(Trim(GetTransactions.LastName)) NEQ 0) AND (Len(Trim(GetTransactions.FirstName)) NEQ 0) )>
		<CFSET InsuredName = Trim(GetTransactions.LastName) & ", ">
		<CFSET InsuredName = InsuredName & Trim(GetTransactions.FirstName) & " ">
		<CFIF Len(Trim(GetTransactions.MiddleInitial)) NEQ 0>
			<CFSET InsuredName = InsuredName & Trim(GetTransactions.MiddleInitial)>
		</CFIF>
	<cfelse>
		<cfset InsuredName = Trim(GetTransactions.BusinessName) & " dba " & Trim(GetTransactions.BusinessName)>
	</cfif>
	<CFSET InsuredName = Left(InsuredName, 35)>


	<!--- Total currency values --->
	<CFSET totalGrossPremium = totalGrossPremium + GetTransactions.GrossPremium>
	<cfset variables.KyMunicipalTax = 0>
	<cfset variables.KyCollectionFee = 0>
	<cfset variables.Surcharge = 0>


	<!--- If transaction has surcharges, get them --->
	<cfif GetTransactions.NumSurcharges GT 0>
		<cfset variables.TransactionID = GetTransactions.TransactionID>
		<cfinclude template="../QRY/QRY_GetTransactionSurcharges.cfm">

		<!--- Check for surcharges --->
		<cfloop query="GetTransactionSurcharges">
			<!--- Determine nature of the surcharge --->
			<cfif CompareNoCase(GetTransactionSurcharges.Surcharge, "KY-Municipal (Docs)") EQ 0>
				<!--- If KY Municipal Tax, report it --->
				<cfset totalKyMunicipalTax = totalKyMunicipalTax + GetTransactionSurcharges.SurchargeAmount>
				<cfset variables.KyMunicipalTax = GetTransactionSurcharges.SurchargeAmount>
			<cfelseif CompareNoCase(GetTransactionSurcharges.Surcharge, "KY-LGPT Tax (Docs)") EQ 0>
				<!--- If KY Collection Fee, report it --->
				<cfset totalKyCollectionFee = totalKyCollectionFee + GetTransactionSurcharges.SurchargeAmount>
				<cfset variables.KyCollectionFee = GetTransactionSurcharges.SurchargeAmount>
			<cfelse>
				<!--- If some other surcharge, report it --->
				<cfset totalSurcharge = totalSurcharge + GetTransactionSurcharges.SurchargeAmount>
				<cfset variables.Surcharge = GetTransactionSurcharges.SurchargeAmount>
			</cfif>
		</cfloop>
	</cfif>




	<!--- If transaction is a "Tail", change code from 10 to 6 to meet AIG specs --->
	<CFIF GetTransactions.TransactionCodeID EQ 10>
		<CFSET VARIABLES.TransactionCodeID = 6>
	<CFELSE>
		<CFSET VARIABLES.TransactionCodeID = GetTransactions.TransactionCodeID>
	</CFIF>


	<!--- Build Policy Record --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.pcFeedSequenceNumber, "0", "RIGHT", 3)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.producerNumber, "0", "RIGHT", 9)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(VARIABLES.generationTimeStamp, "0", "RIGHT", 13)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & "P">
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.pcPolicySymbol, " ", "LEFT", 3)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.PolicyNumber, "0", "RIGHT", 9)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.masterCertAndDecNumber, "0", "RIGHT", 11)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.locationNumber, "0", "RIGHT", 3)>
<!--- START: Policy Module Number --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.PolicyModuleNumber, "0", "RIGHT", 2)>
<!--- END: Policy Module Number --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.InsuranceCompanyID, "0", "RIGHT", 3)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.PreviousPolicyNumber, "0", "RIGHT", 9)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.previousCertNumber, "0", "RIGHT", 11)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(GetTransactions.PolicyEffectiveDate, "YYYYMMDD"), "0", "RIGHT", 8)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(GetTransactions.PolicyExpirationDate, "YYYYMMDD"), "0", "RIGHT", 8)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(InsuredName, " ", "LEFT", 35)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.Address, " ", "LEFT", 35)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.City, " ", "LEFT", 18)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.Abbreviation, " ", "LEFT", 2)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.ZipCode, " ", "LEFT", 5)>
	<CFIF Compare(GetTransactions.ZipCode2, "0000") NEQ 0>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.ZipCode2, " ", "LEFT", 4)>
	<CFELSE>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue("", " ", "LEFT", 4)>
	</CFIF>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.eStartSubmissionNumber, "0", "RIGHT", 9)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.GrossPremium GTE 0, DE("+"), DE("-"))>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(GetTransactions.GrossPremium), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(variables.KyMunicipalTax GTE 0, DE("+"), DE("-"))>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(variables.KyMunicipalTax), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(variables.KyCollectionFee GTE 0, DE("+"), DE("-"))>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(variables.KyCollectionFee), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(variables.Surcharge GTE 0, DE("+"), DE("-"))>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(variables.Surcharge), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.agencyBillIndicator, " ", "LEFT", 1)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.pcBranchNumber, " ", "LEFT", 2)>

	<!--- If Surplus Lines in NJ, include NJ Surplus Lines info --->
	<CFIF (CompareNoCase(GetTransactions.Abbreviation, "NJ") EQ 0) AND (GetTransactions.InsuranceCompanyID EQ 41)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.njSurplusLinesLicenseNumber & "-" & DateFormat(GetTransactions.TransactionEffectiveDate, "YY") & "-" & GetTransactions.NjSequenceNumber, " ", "LEFT", 14)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.surplusLinesAgentsName, " ", "LEFT", 35)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.surplusLinesAgentsAddress, " ", "LEFT", 35)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.surplusLinesAgentsCity, " ", "LEFT", 18)>
	<CFELSE>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 102)>
	</CFIF>

	<!--- Determine payment plan type --->
	<cfif variables.TransactionCodeID GT 2>
		<!--- Any transaction other than "New Business" (1) or "Renewal" (2) must use "Pre-paid" (02) payment plan --->
		<cfset variables.BuildExport = variables.BuildExport & UDF_padValue("02", "0", "RIGHT", 2)>
	<cfelse>
		<!--- For "New Business" (1) or "Renewal" (2) transactions, use specified payment plan --->
		<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(GetTransactions.PaymentPlanCode, "0", "RIGHT", 2)>
	</cfif>

	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 10)>	<!--- Filler --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 3)>	<!--- Filler --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 2)>	<!--- Filler --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 14)>	<!--- Filler --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 35)>	<!--- Filler --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 4)>	<!--- Insured Country Code --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 10)>	<!--- Insured Phone No. --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 70)>	<!--- Filler --->

	<!--- If non-admitted business (Lexington), include Surplus Lines info --->
	<cfif GetTransactions.InsuranceCompanyID EQ 41>
		<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(GetTransactions.Abbreviation, " ", "LEFT", 2)>	<!--- Home State Code --->
		<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(GetTransactions.SurplusLinesLicenseNumber, " ", "LEFT", 15)>	<!--- Home State License Number --->
	<cfelse>
		<cfset variables.BuildExport = variables.BuildExport & RepeatString(" ", 17)>	<!--- Filler --->
	</cfif>

	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 71)>	<!--- Filler --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & CrLf>



	<!--- Build Installment Record --->
	<!--- Installment records only necessary for new business paying in installments --->
	<cfif (ListFind("1,2", GetTransactions.TransactionCodeID) NEQ 0) AND (Compare(GetTransactions.PaymentPlanCode, "05") EQ 0)>
		<!--- Calculate down payment: 30% of GrossPremium --->
		<cfset variables.InstallmentPaymentTotal = GetTransactions.GrossPremium>
		<cfset variables.InstallmentDownPayment = RoundPlus2(GetTransactions.GrossPremium * 0.30)>
		<cfset variables.InstallmentPaymentBalance = variables.InstallmentPaymentTotal - variables.InstallmentDownPayment>
		<cfset variables.InstallmentPaymentSubTotal = 0>

		<!--- Determine number of installments --->
		<cfif CompareNoCase(GetTransactions.PaymentPlan, "30% DP, 3 Bi-mthly pmts") EQ 0>
			<cfset variables.NumInstallments = 4>
		<cfelseif CompareNoCase(GetTransactions.PaymentPlan, "30% DP, 4 Bi-mthly pmts") EQ 0>
			<cfset variables.NumInstallments = 5>
		</cfif>

		<!--- Initialize date of first payment --->
		<cfset variables.InstallmentStartDate = DateFormat(GetTransactions.PolicyEffectiveDate, "mm/dd/yyyy")>

		<!--- Create Installment records --->
		<cfloop from="1" to="#variables.NumInstallments#" index="variables.Installment">
			<!--- Determine installment amount --->
			<cfif variables.Installment EQ 1>
				<!--- First installment, payment = down payment --->
				<cfset variables.InstallmentAmount = variables.InstallmentDownPayment>
				<cfset variables.InstallmentPaymentSubTotal = variables.InstallmentDownPayment>
			<cfelseif variables.Installment EQ variables.NumInstallments>
				<cfset variables.InstallmentAmount = variables.InstallmentPaymentTotal - variables.InstallmentPaymentSubTotal>
				<cfset variables.InstallmentPaymentSubTotal = variables.InstallmentPaymentSubTotal + variables.InstallmentAmount>
			<cfelse>
				<cfset variables.InstallmentAmount = RoundPlus2(variables.InstallmentPaymentBalance / (variables.NumInstallments - 1))>
				<cfset variables.InstallmentPaymentSubTotal = variables.InstallmentPaymentSubTotal + variables.InstallmentAmount>
			</cfif>

			<!--- Determine installment date --->
			<cfset variables.InstallmentDate = DateAdd("m", ((variables.Installment - 1) * 2), variables.InstallmentStartDate)>

			<!--- Output record data --->
			<cfset variables.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.pcFeedSequenceNumber, "0", "RIGHT", 3)>
			<cfset variables.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.producerNumber, "0", "RIGHT", 9)>
			<cfset variables.BuildExport = VARIABLES.BuildExport & UDF_padValue(VARIABLES.generationTimeStamp, "0", "RIGHT", 13)>
			<cfset variables.BuildExport = VARIABLES.BuildExport & "I">
			<cfset variables.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.pcPolicySymbol, " ", "LEFT", 3)>
			<cfset variables.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.PolicyNumber, "0", "RIGHT", 9)>
			<cfset variables.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.masterCertAndDecNumber, "0", "RIGHT", 11)>
			<cfset variables.BuildExport = VARIABLES.BuildExport & UDF_padValue(variables.Installment, "0", "RIGHT", 3)>
			<cfset variables.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(variables.InstallmentDate, "YYYYMMDD"), "0", "RIGHT", 8)>
			<cfset variables.BuildExport = VARIABLES.BuildExport & IIF(variables.InstallmentAmount GTE 0, DE("+"), DE("-"))>
			<cfset variables.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(variables.InstallmentAmount), "_________.__"), ".", "", "ALL"), "0", "RIGHT", 11)>
			<cfset variables.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 526)>	<!--- Filler --->
			<cfset variables.BuildExport = VARIABLES.BuildExport & CrLf>
		</cfloop>
	</cfif>




	<!--- Build Location Record --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.pcFeedSequenceNumber, "0", "RIGHT", 3)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.producerNumber, "0", "RIGHT", 9)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(VARIABLES.generationTimeStamp, "0", "RIGHT", 13)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & "L">
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.pcPolicySymbol, " ", "LEFT", 3)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.PolicyNumber, "0", "RIGHT", 9)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.masterCertAndDecNumber, "0", "RIGHT", 11)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.locationNumber, "0", "RIGHT", 3)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.RiskLocationCode, "0", "RIGHT", 6)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.Address, " ", "LEFT", 35)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.City, " ", "LEFT", 18)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.Abbreviation, " ", "LEFT", 2)>
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.ZipCode, " ", "LEFT", 5)>
	<CFIF Compare(GetTransactions.ZipCode2, "0000") NEQ 0>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.ZipCode2, " ", "LEFT", 4)>
	<CFELSE>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue("", " ", "LEFT", 4)>
	</CFIF>
	<!--- Only include Surplus Lines License Number if not NJ and not Nat Union --->
<!---
	<CFIF (GetTransactions.InsuranceCompanyID EQ 29) OR (CompareNoCase(GetTransactions.Abbreviation, "NJ") EQ 0)>
 --->
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 15)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 2)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.FEIN, "0", "RIGHT", 9)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 35)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 35)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 18)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 2)>
<!---
	<CFELSE>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.SurplusLinesLicenseNumber, " ", "LEFT", 15)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.Abbreviation, " ", "LEFT", 2)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.FEIN, "0", "RIGHT", 9)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.surplusLinesAgentsName, " ", "LEFT", 35)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.surplusLinesAgentsAddress, " ", "LEFT", 35)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.surplusLinesAgentsCity, " ", "LEFT", 18)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.surplusLinesAgentsState, " ", "LEFT", 2)>
	</CFIF>
 --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 362)>	<!--- Filler --->
	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & CrLf>


	<!--- Build Coverage Record --->
	<cfloop from="1" to="#1 + GetTransactions.NumSurcharges#" index="loopCtr">
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.pcFeedSequenceNumber, "0", "RIGHT", 3)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.producerNumber, "0", "RIGHT", 9)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(VARIABLES.generationTimeStamp, "0", "RIGHT", 13)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & "C">
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.pcPolicySymbol, " ", "LEFT", 3)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.PolicyNumber, "0", "RIGHT", 9)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.masterCertAndDecNumber, "0", "RIGHT", 11)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.locationNumber, "0", "RIGHT", 3)>
<!--- 	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.coverageNumber, "0", "RIGHT", 3)>	--->
		<!--- Coverage Number --->
		<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(loopCtr, "0", "RIGHT", 3)>
		<!--- // Coverage Number --->
		<CFIF Len(Trim(GetTransactions.CoverageSymbol)) EQ 0>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.coverageSymbol, " ", "LEFT", 4)>
		<CFELSE>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.CoverageSymbol, " ", "LEFT", 4)>
		</CFIF>
<!---	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.coverageMajorClass, "0", "RIGHT", 3)> --->
		<!--- Coverage Major Class --->
		<cfif (GetTransactions.NumSurcharges EQ 0) OR (loopCtr EQ 1)>
			<cfif CompareNoCase(Right(GetTransactions.CoverageSymbol, 2), "CM") EQ 0>
				<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(659, "0", "RIGHT", 3)>
			<cfelse>
				<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(359, "0", "RIGHT", 3)>
			</cfif>
		<cfelse>
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(88, "0", "RIGHT", 3)>
		</cfif>
		<!--- // Coverage Major Class --->
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(GetTransactions.TransactionEffectiveDate, "YYYYMMDD"), "0", "RIGHT", 8)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(GetTransactions.TransactionExpirationDate, "YYYYMMDD"), "0", "RIGHT", 8)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(VARIABLES.TransactionCodeID, "0", "RIGHT", 2)>
		<!--- Determine if we're reporting premium or surcharge --->
		<cfif (GetTransactions.NumSurcharges EQ 0) OR (loopCtr EQ 1)>
			<!--- If first record, report premium --->
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.GrossPremium GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(GetTransactions.GrossPremium), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(stSystemConstants.commissionRate), "__._____"), ".", "", "ALL"), "0", "LEFT", 7)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.KyMunicipalTax GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.KyCollectionFee GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.Surcharge GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<cfelseif CompareNoCase(GetTransactionSurcharges.Surcharge[loopCtr - 1], "KY-Municipal (Docs)") EQ 0>
			<!--- If KY Municipal Tax, report it --->
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.GrossPremium GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(stSystemConstants.commissionRate), "__._____"), ".", "", "ALL"), "0", "LEFT", 7)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactionSurcharges.SurchargeAmount GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(GetTransactionSurcharges.SurchargeAmount[loopCtr - 1]), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.KyCollectionFee GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.Surcharge GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<cfelseif CompareNoCase(GetTransactionSurcharges.Surcharge[loopCtr - 1], "KY-LGPT Tax (Docs)") EQ 0>
			<!--- If KY Collection Fee, report it --->
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.GrossPremium GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(stSystemConstants.commissionRate), "__._____"), ".", "", "ALL"), "0", "LEFT", 7)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.KyMunicipalTax GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactionSurcharges.SurchargeAmount GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(GetTransactionSurcharges.SurchargeAmount[loopCtr - 1]), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.Surcharge GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<cfelse>
			<!--- If some other surcharge, report it --->
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.GrossPremium GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(stSystemConstants.commissionRate), "__._____"), ".", "", "ALL"), "0", "LEFT", 7)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.KyMunicipalTax GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactions.KyCollectionFee GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(0, "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(GetTransactionSurcharges.SurchargeAmount GTE 0, DE("+"), DE("-"))>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(GetTransactionSurcharges.SurchargeAmount[loopCtr - 1]), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		</cfif>
		<!--- // Determine if we're reporting premium or surcharge --->
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Int(GetTransactions.LimitAmountPerClaim), "0", "RIGHT", 9)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Int(GetTransactions.LimitAmountAggregate), "0", "RIGHT", 9)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Int(GetTransactions.DeductibleAmountPerClaim), "0", "RIGHT", 9)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Int(GetTransactions.DeductibleAmountAggregate), "0", "RIGHT", 9)>

<!---	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.policyFormCode, " ", "RIGHT", 1)>	--->
		<cfif CompareNoCase(Right(GetTransactions.CoverageSymbol, 2), "CM") EQ 0>
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue("C", " ", "RIGHT", 1)>
		<cfelse>
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue("O", " ", "RIGHT", 1)>
		</cfif>


		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.tailDate, "0", "RIGHT", 8)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(GetTransactions.PolicyRetroactiveDate, "YYYYMMDD"), "0", "RIGHT", 8)>
<!---	<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.statPlanNumber, "0", "RIGHT", 2)> --->
		<!--- Stat Plan Number & Details --->
		<cfif (GetTransactions.NumSurcharges EQ 0) OR (loopCtr EQ 1)>
			<!--- If we're reporting premium, use Stat Plan 29 --->
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(29, "0", "RIGHT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(GetTransactions.PolicyEffectiveDate, "MM"), "0", "RIGHT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(GetTransactions.PolicyEffectiveDate, "YY"), "0", "RIGHT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.terrorismTypeCode, "0", "RIGHT", 1)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.mgaTransaction, "0", "RIGHT", 1)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 1)>	<!--- Filler --->
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.policyType, "0", "RIGHT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 16)>	<!--- Filler --->
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.biLimitCode, " ", "LEFT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.biDeductibleCode, " ", "LEFT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.coverageMajorClass, "0", "RIGHT", 4)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.exposureBase, " ", "LEFT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.exposureAmount, "0", "RIGHT", 7)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 12)>	<!--- Filler --->
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.rateExperience, " ", "LEFT", 3)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.rateSchedule, " ", "LEFT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.ratePackage, " ", "LEFT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.rateExpense, " ", "LEFT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.rateCommission, " ", "LEFT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.rateDeductible, " ", "LEFT", 2)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.ZipCode, " ", "LEFT", 5)>
			<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.limitedCoding, "0", "RIGHT", 1)>
		<cfelse>
			<!--- If we're reporting surcharge, use Stat Plan 00 --->
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(0, "0", "RIGHT", 2)>
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(GetTransactionSurcharges.AssessmentCode[loopCtr - 1], " ", "LEFT", 5)>
			<cfset variables.BuildExport = variables.BuildExport & RepeatString(" ", 68)>	<!--- Filler --->
		</cfif>
		<!--- // Stat Plan Number & Details --->
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 329)>	<!--- Filler --->
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & CrLf>
	</cfloop>
	<!--- // End coverage record --->
</CFLOOP>


<!--- Build Trailer Record --->
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.pcFeedSequenceNumber, "0", "RIGHT", 3)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.producerNumber, "0", "RIGHT", 9)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(VARIABLES.generationTimeStamp, "0", "RIGHT", 13)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & "T">
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString("9", 26)>	<!--- Filler --->
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.RecordCount, "0", "RIGHT", 6)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(totalGrossPremium GTE 0, DE("+"), DE("-"))>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(totalGrossPremium), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(totalKyMunicipalTax GTE 0, DE("+"), DE("-"))>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(totalKyMunicipalTax), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
<!--- START: KY State Surcharge --->
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(totalKyCollectionFee GTE 0, DE("+"), DE("-"))>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(totalKyCollectionFee), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
<!--- END: KY State Surcharge --->
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(totalSurcharge GTE 0, DE("+"), DE("-"))>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(totalSurcharge), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 486)>	<!--- Filler --->
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & CrLf>
