<!---
################################################################################
#
# Filename:		BIZ_buildAccountsCurrentExport.cfm
#
# Description:	Builds an Accounts Current export from the GetTransactions QRS
#
################################################################################
--->

<!--- Initialize variables --->
<CFSET VARIABLES.BuildExport = "">
<CFSET currInsuranceCompanyID = 0>
<CFSET accountCurrentSequenceNumber = 0>
<cfset variables.affectedInstallmentPolicies = "">
<cfset variables.affectedFullPayPolicies = "">


<!--- Initialize grand total trailer variables --->
<CFSET grandTotalGrossPremium = 0>
<CFSET grandTotalSurcharge = 0>
<CFSET grandTotalCommission = 0>
<CFSET grandTotalNetPremium = 0>
<CFSET grandTotalRecordCount = 0>


<!--- Determine Account Current Date --->
<CFSET VARIABLES.AccountCurrentDate = VARIABLES.ExportDate>



<!--- Build Data Records --->
<CFLOOP FROM="1" TO="#GetTransactions.RecordCount#" INDEX="idx">
	<!--- Check if we should include current record in current feed --->
	<cfset variables.include = true>

	<!--- Initialize trailer variables for new Insurance Company --->
	<CFIF GetTransactions.InsuranceCompanyID[idx] NEQ currInsuranceCompanyID>
		<CFSET currInsuranceCompanyID = GetTransactions.InsuranceCompanyID[idx]>
		<CFSET totalGrossPremium = 0>
		<CFSET totalSurcharge = 0>
		<CFSET totalCommission = 0>
		<CFSET totalNetPremium = 0>
		<CFSET totalRecordCount = 0>
		<CFSET accountCurrentSequenceNumber = accountCurrentSequenceNumber + 1>
	</CFIF>

	<!--- For installment policies that are not new, check if they have a scheduled installment for this month --->
	<cfif (Compare(GetTransactions.PaymentPlanCode[idx], "05") EQ 0)>
		<!--- Get current policy's installment schedule dates --->
		<cfset variables.installmentSchedule = GetTransactions.InstallmentDates[idx]>

		<!--- Iterate over dates to see if we have one that matches for current feed --->
		<cfset variables.include = false>
		<cfloop from="#GetTransactions.InstallmentPaidNum[idx] + 1#" to="#GetTransactions.InstallmentTotalNum[idx]#" index="currInst">
			<cfif (Len(Trim(variables.RangeStartDate)) NEQ 0) AND (Len(Trim(variables.RangeEndDate)) NEQ 0) AND (DateDiff("d", DateFormat(variables.RangeStartDate, "mm/dd/yyyy"), ListGetAt(variables.installmentSchedule, currInst)) GTE 0) AND (DateDiff("d", ListGetAt(variables.installmentSchedule, currInst), DateFormat(variables.RangeEndDate, "mm/dd/yyyy")) GTE 0)>
				<cfset variables.include = true>

				<!--- If first installment, update installment *and* export date --->
				<cfif currInst EQ 1>
					<cfset variables.affectedFullPayPolicies = ListAppend(variables.affectedFullPayPolicies, GetTransactions.TransactionID[idx])>
				<cfelse>
					<cfset variables.affectedInstallmentPolicies = ListAppend(variables.affectedInstallmentPolicies, GetTransactions.TransactionID[idx])>
				</cfif>
			<cfelseif (Len(Trim(variables.RangeStartDate)) EQ 0) AND (Len(Trim(variables.RangeEndDate)) EQ 0) AND (DateDiff("d", DateFormat(variables.ExportDate, "mm/dd/yyyy"), ListGetAt(variables.installmentSchedule, currInst)) GTE 0)>
				<cfset variables.include = true>

				<!--- If first installment, update installment *and* export date --->
				<cfif currInst EQ 1>
					<cfset variables.affectedFullPayPolicies = ListAppend(variables.affectedFullPayPolicies, GetTransactions.TransactionID[idx])>
				<cfelse>
					<cfset variables.affectedInstallmentPolicies = ListAppend(variables.affectedInstallmentPolicies, GetTransactions.TransactionID[idx])>
				</cfif>
			</cfif>
		</cfloop>
	<cfelse>
		<cfset variables.affectedFullPayPolicies = ListAppend(variables.affectedFullPayPolicies, GetTransactions.TransactionID[idx])>
	</cfif>


	<!--- Check if current transaction should be included --->
	<cfif variables.include>
		<!--- Build Insured Name - "Last, First MI" or "Business Name as dba Business Name" --->
		<cfif ( (Len(Trim(GetTransactions.LastName[idx])) NEQ 0) AND (Len(Trim(GetTransactions.FirstName[idx])) NEQ 0) )>
			<CFSET InsuredName = Trim(GetTransactions.LastName[idx]) & ", ">
			<CFSET InsuredName = InsuredName & Trim(GetTransactions.FirstName[idx]) & " ">
			<CFIF Len(Trim(GetTransactions.MiddleInitial[idx])) NEQ 0>
				<CFSET InsuredName = InsuredName & Trim(GetTransactions.MiddleInitial[idx])>
			</CFIF>
		<cfelse>
			<cfset InsuredName = Trim(GetTransactions.BusinessName[idx]) & " dba " & Trim(GetTransactions.BusinessName[idx])>
		</cfif>
		<CFSET InsuredName = Left(InsuredName, 35)>


		<!--- Determine reported transaction effective date and premium based on full-pay vs. installment --->
		<cfif Compare(GetTransactions.PaymentPlanCode[idx], "02") EQ 0>
			<!--- Full pay --->
			<cfset variables.premium = GetTransactions.GrossPremium[idx]>
			<cfset variables.surcharge = GetTransactions.Surcharge[idx]>
			<cfset variables.transEffDate = GetTransactions.TransactionEffectiveDate[idx]>
		<cfelseif GetTransactions.InstallmentPaidNum[idx] EQ 0>
			<!--- Installment; first payment --->
			<cfset variables.premium = ListFirst(GetTransactions.InstallmentAmounts[idx])>
			<cfset variables.surcharge = GetTransactions.Surcharge[idx]>
			<cfset variables.transEffDate = ListFirst(GetTransactions.InstallmentDates[idx])>
		<cfelse>
			<!--- Installment; non-first payment --->
			<cfset variables.premium = ListGetAt(GetTransactions.InstallmentAmounts[idx], GetTransactions.InstallmentPaidNum[idx] + 1)>
			<cfset variables.surcharge = 0>
			<cfset variables.transEffDate = ListGetAt(GetTransactions.InstallmentDates[idx], GetTransactions.InstallmentPaidNum[idx] + 1)>
		</cfif>


		<!--- Build commission and net  --->
<!---
		<cfif CompareNoCase(GetTransactions.CoverageBasis[idx], "O") EQ 0>
			<cfset commission = variables.premium * 20 / 100>
		<cfelse>
			<cfset commission = variables.premium * 21 / 100>
		</cfif>
 --->
		<cfif DateCompare(DateFormat(GetTransactions.PolicyEffectiveDate, "mm/dd/yyyy"), "01/01/2016") GTE 0>
			<cfset commission = variables.premium * 23 / 100>
		<cfelseif CompareNoCase(GetTransactions.CoverageBasis[idx], "O") EQ 0>
			<cfset commission = variables.premium * 20 / 100>
		<cfelse>
			<cfset commission = variables.premium * 21 / 100>
		</cfif>

		<CFSET commission = Round(commission * 100) / 100>
		<CFSET netPremium = variables.premium + variables.surcharge - commission>
		<CFSET netPremium = Round(netPremium * 100) / 100>

		<!--- Total trailer and grand trailer record values --->
		<CFSET totalGrossPremium = totalGrossPremium + variables.premium>
		<CFSET grandTotalGrossPremium = grandTotalGrossPremium + variables.premium>
		<CFSET totalSurcharge = totalSurcharge + variables.surcharge>
		<CFSET grandTotalSurcharge = grandTotalSurcharge + variables.surcharge>
		<CFSET totalCommission = totalCommission + commission>
		<CFSET grandTotalCommission = grandTotalCommission + commission>
		<CFSET totalNetPremium = totalNetPremium + netPremium>
		<CFSET grandTotalNetPremium = grandTotalNetPremium + netPremium>
		<CFSET totalRecordCount = totalRecordCount + 1>
		<CFSET grandTotalRecordCount = grandTotalRecordCount + 1>


		<!--- If transaction is a "Tail", change code from 10 to 6 to meet AIG specs --->
		<CFIF GetTransactions.TransactionCodeID[idx] EQ 10>
			<CFSET GetTransactions.TransactionCodeID[idx] = 6>
		</CFIF>


		<!--- Build record --->
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.acFeedSequenceNumber, "0", "RIGHT", 3)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue("DT", "", "LEFT", 2)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.producerNumber, "0", "RIGHT", 9)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(VARIABLES.AccountCurrentDate, "YYYYMMDD"), "0", "RIGHT", 8)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(accountCurrentSequenceNumber, "0", "RIGHT", 4)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.TransactionCodeID[idx], "0", "RIGHT", 2)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.InsuranceCompanyID[idx], "0", "RIGHT", 3)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.acPolicySymbol, " ", "LEFT", 3)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(GetTransactions.PolicyNumber[idx], "0", "RIGHT", 9)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(InsuredName, " ", "LEFT", 35)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(GetTransactions.PolicyEffectiveDate[idx], "YYYYMMDD"), "0", "RIGHT", 8)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.lineOfBusiness, " ", "LEFT", 4)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(variables.transEffDate, "YYYYMMDD"), "0", "RIGHT", 8)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(GetTransactions.TransactionExpirationDate[idx], "YYYYMMDD"), "0", "RIGHT", 8)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(variables.premium GTE 0, DE("+"), DE("-"))>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(variables.premium), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(variables.surcharge GTE 0, DE("+"), DE("-"))>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(variables.surcharge), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(stSystemConstants.commissionRate GTE 0, DE("+"), DE("-"))>
<!---
		<cfif CompareNoCase(GetTransactions.CoverageBasis[idx], "O") EQ 0>
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(Replace(NumberFormat(20, "__._____"), ".", "", "ALL"), "0", "LEFT", 7)>
		<cfelse>
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(Replace(NumberFormat(21, "__._____"), ".", "", "ALL"), "0", "LEFT", 7)>
		</cfif>
 --->
		<cfif DateCompare(DateFormat(GetTransactions.PolicyEffectiveDate, "mm/dd/yyyy"), "01/01/2016") GTE 0>
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(Replace(NumberFormat(23, "__._____"), ".", "", "ALL"), "0", "LEFT", 7)>
		<cfelseif CompareNoCase(GetTransactions.CoverageBasis[idx], "O") EQ 0>
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(Replace(NumberFormat(20, "__._____"), ".", "", "ALL"), "0", "LEFT", 7)>
		<cfelse>
			<cfset variables.BuildExport = variables.BuildExport & UDF_padValue(Replace(NumberFormat(21, "__._____"), ".", "", "ALL"), "0", "LEFT", 7)>
		</cfif>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(commission GTE 0, DE("+"), DE("-"))>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(commission), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(netPremium GTE 0, DE("+"), DE("-"))>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(netPremium), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.premiumRecordType, " ", "LEFT", 1)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.adjustmentIndicator, " ", "LEFT", 1)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.aicoIndicator, " ", "LEFT", 1)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.aigrmContractNumber, "0", "RIGHT", 10)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 97)>	<!--- Comments --->
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 20)>	<!--- Filler --->
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & CrLf>
	</cfif>

	<!--- If end of query or new InsuranceCompanyID is coming up, attach trailer record --->
	<CFIF (GetTransactions.RecordCount EQ idx) OR (GetTransactions.InsuranceCompanyID[idx + 1] NEQ currInsuranceCompanyID)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.acfeedSequenceNumber, "0", "RIGHT", 3)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue("TR", "", "LEFT", 2)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.producerNumber, "0", "RIGHT", 9)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.divisionCode, "0", "RIGHT", 3)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(VARIABLES.AccountCurrentDate, "YYYYMMDD"), "0", "RIGHT", 8)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(accountCurrentSequenceNumber, "0", "RIGHT", 4)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.acBranchNumber, "0", "RIGHT", 3)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(totalGrossPremium GTE 0, DE("+"), DE("-"))>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(totalGrossPremium), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(totalSurcharge GTE 0, DE("+"), DE("-"))>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(totalSurcharge), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(totalCommission GTE 0, DE("+"), DE("-"))>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(totalCommission), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(totalNetPremium GTE 0, DE("+"), DE("-"))>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(totalNetPremium), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(totalRecordCount, "0", "RIGHT", 6)>
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 176)>	<!--- Comments --->
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 30)>	<!--- Filler --->
		<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & CrLf>
	</CFIF>
</CFLOOP>


<!--- Determine Grand Total Trailer Record sequence number --->
<CFIF accountCurrentSequenceNumber EQ 1>
	<CFSET gtAccountCurrentSequenceNumber = 1>
<CFELSE>
	<CFSET gtAccountCurrentSequenceNumber = 0>
</CFIF>

<!--- Build Grand Total Trailer Record --->
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.acfeedSequenceNumber, "0", "RIGHT", 3)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue("GT", "", "LEFT", 2)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.producerNumber, "0", "RIGHT", 9)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.divisionCode, "0", "RIGHT", 3)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(DateFormat(VARIABLES.AccountCurrentDate, "YYYYMMDD"), "0", "RIGHT", 8)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(gtAccountCurrentSequenceNumber, "0", "RIGHT", 4)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(stSystemConstants.acBranchNumber, "0", "RIGHT", 3)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(grandTotalGrossPremium GTE 0, DE("+"), DE("-"))>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(grandTotalGrossPremium), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(grandTotalSurcharge GTE 0, DE("+"), DE("-"))>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(grandTotalSurcharge), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(grandTotalCommission GTE 0, DE("+"), DE("-"))>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(grandTotalCommission), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & IIF(grandTotalNetPremium GTE 0, DE("+"), DE("-"))>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(Replace(NumberFormat(Abs(grandTotalNetPremium), "___________.__"), ".", "", "ALL"), "0", "RIGHT", 13)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & UDF_padValue(grandTotalRecordCount, "0", "RIGHT", 6)>
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 176)>	<!--- Comments --->
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & RepeatString(" ", 30)>	<!--- Filler --->
<CFSET VARIABLES.BuildExport = VARIABLES.BuildExport & CrLf>

