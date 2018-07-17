<!---
################################################################################
#
# Filename:		importAction.cfm
#
# Description:	Import Action page
#
################################################################################
--->


<!--- Upload file --->
<cffile action="upload" filefield="FileName" nameconflict="MakeUnique" destination="#GetTempDirectory()#">

<!--- Import contents of spreadsheet into query object --->
<cfspreadsheet action="read" src="#file.serverDirectory#\#file.serverFile#" query="qryExcel" headerRow="1" excludeHeaderRow="true" columnnames="LastName,FirstName,MiddleName,BusinessName,Address,City,State,County,Zip,Fein,TransactionCode,TransactionEffectiveDate,TransactionExpirationDate,GrossPremium,KyCollectionFee,KyMunicipalTax,LimitAmountPerClaim,LimitAmountAggregate,DeductibleAmountPerClaim,DeductibleAmountAggregate,PolicyNumber,PreviousPolicyNumber,PolicyEffectiveDate,PolicyExpirationDate,PolicyRetroactiveDate,InsuranceCompany,NjSequenceNumber,SpecialtyCoverages,CoverageSymbol,CoverageBasis,PayPlan,ChargeType1,Amount1,ChargeType2,Amount2,ChargeType3,Amount3,ChargeType4,Amount4,ChargeType5,Amount5">

<!--- Move/rename uploaded file --->
<cffile action="move" source="#file.serverDirectory#\#file.serverFile#" destination="#ExpandPath(".\Uploads\" & DateFormat(Now(), "yyyymmdd") & "_" & TimeFormat(Now(), "HHmmss") & "_Ams360Report.xlsx")#">


<!--- Get lookup values --->
<cfinclude template="QRY/QRY_GetTransactionCodes.cfm">
<cfinclude template="QRY/QRY_GetStates.cfm">
<cfinclude template="QRY/QRY_GetInsuranceCompanies.cfm">
<cfinclude template="QRY/QRY_GetPaymentPlans.cfm">
<cfinclude template="QRY/QRY_GetCoverageSymbols.cfm">
<cfinclude template="QRY/QRY_GetStateSurcharges.cfm">


<!--- Build lookup structs --->
<cfset states = StructNew()>
<cfloop query="GetStates">
	<cfset states[GetStates.Abbreviation] = GetStates.StateID>
</cfloop>

<cfset paymentPlans = StructNew()>
<cfloop query="GetPaymentPlans">
	<cfset paymentPlans[GetPaymentPlans.PaymentPlan] = GetPaymentPlans.PaymentPlanCode>
</cfloop>


<!--- Preset constants --->
<cfset form.ZipCode2 = "0000">
<cfset form.CookCountyInd = 0>
<cfset form.Surcharge = 0>
<cfset form.PolicySymbol = "#stSystemConstants.acPolicySymbol#">
<cfset form.PolicyModuleNumber = 0>
<cfset form.PremiumCodingExportDateTimeInd = 0>
<cfset form.AccountsCurrentExportDateTimeInd = 0>


<!--- Initialize variables --->
<cfset ctr = 0>
<cfset errorInd = false>
<cfset errors = StructNew()>


<!--- Iterate over records --->
<cfloop query="qryExcel">
	<!--- Make sure row isn't blank --->
	<cfif Len(Trim( qryExcel.LastName & qryExcel.FirstName & qryExcel.BusinessName & qryExcel.Address & qryExcel.City & qryExcel.State )) NEQ 0>

		<!--- Increment counter --->
		<cfset ctr = ctr + 1>


		<!--- Reset variables --->
		<cfset form.ClientID = "">
		<cfset form.LastName = "">
		<cfset form.FirstName = "">
		<cfset form.MiddleInitial = "">
		<cfset form.BusinessName = "">
		<cfset form.Address = "">
		<cfset form.City = "">
		<cfset form.StateID = "">
		<cfset form.ZipCode = "">
		<cfset form.FEIN = "">
		<cfset form.TransactionCodeID = "">
		<cfset form.TransactionEffectiveDate = "">
		<cfset form.TransactionExpirationDate = "">
		<cfset form.GrossPremium = "">
		<cfset form.KyCollectionFee = "">
		<cfset form.KyMunicipalTax = "">
		<cfset form.LimitAmountPerClaim = "">
		<cfset form.LimitAmountAggregate = "">
		<cfset form.DeductibleAmountPerClaim = "">
		<cfset form.DeductibleAmountAggregate = "">
		<cfset form.CoverageSymbol = "">
		<cfset form.PolicyNumber = "">
		<cfset form.PolicyModuleNumber = "0">
		<cfset form.PreviousPolicyNumber = "">
		<cfset form.PolicyEffectiveDate = "">
		<cfset form.PolicyExpirationDate = "">
		<cfset form.PolicyRetroactiveDate = "">
		<cfset form.InsuranceCompanyID = "">
		<cfset form.NJSequenceNumber = "">
		<cfset form.PaymentPlanID = "">
		<cfset form.CoverageBasis = "">
		<cfset form.ChargeType1 = "">
		<cfset form.Amount1 = "">
		<cfset form.ChargeType2 = "">
		<cfset form.Amount2 = "">
		<cfset form.ChargeType3 = "">
		<cfset form.Amount3 = "">
		<cfset form.ChargeType4 = "">
		<cfset form.Amount4 = "">
		<cfset form.ChargeType5 = "">
		<cfset form.Amount5 = "">


		<!--- Set variables based on contents of current excel record --->
		<cfset form.LastName = Trim(ReplaceNoCase(qryExcel.LastName, ", M.D.", "", "ALL"))>
		<cfset form.FirstName = Trim(qryExcel.FirstName)>
		<cfset form.MiddleInitial = Trim(qryExcel.MiddleName)>
		<cfset form.BusinessName = qryExcel.BusinessName>
		<cfset form.Address = qryExcel.Address>
		<cfset form.City = qryExcel.City>
		<cfset form.StateID = states[qryExcel.State]>
		<cfset form.ZipCode = Replace(qryExcel.Zip, "'", "", "ALL")>
		<cfset form.FEIN = qryExcel.FEIN>

		<cfset form.TransactionCodeID = -2>
		<cfloop query="GetTransactionCodes">
			<cfif CompareNoCase(GetTransactionCodes.AmsCode, Left(qryExcel.TransactionCode, Len(GetTransactionCodes.AmsCode))) EQ 0>
				<cfset form.TransactionCodeID = GetTransactionCodes.TransactionCodeID>
			</cfif>
		</cfloop>

		<cfset form.TransactionEffectiveDate = DateFormat(qryExcel.TransactionEffectiveDate, "mm/dd/yyyy")>
		<cfset form.TransactionExpirationDate = DateFormat(qryExcel.TransactionExpirationDate, "mm/dd/yyyy")>
		<cfset form.GrossPremium = qryExcel.GrossPremium>
		<cfset form.KyCollectionFee = qryExcel.KyCollectionFee>
		<cfset form.KyMunicipalTax = qryExcel.KyMunicipalTax>
		<cfset form.LimitAmountPerClaim = Replace(qryExcel.LimitAmountPerClaim, ",", "", "ALL")>
		<cfset form.LimitAmountAggregate = Replace(qryExcel.LimitAmountAggregate, ",", "", "ALL")>
		<cfset form.DeductibleAmountPerClaim = Replace(DeductibleAmountPerClaim, ",", "", "ALL")>
		<cfset form.DeductibleAmountAggregate = Replace(qryExcel.DeductibleAmountAggregate, ",", "", "ALL")>
		<cfset form.CoverageSymbol = qryExcel.CoverageSymbol>
		<cfset form.PolicyNumber = Replace(qryExcel.PolicyNumber, "'", "", "ALL")>
		<cfset form.PreviousPolicyNumber = Replace(qryExcel.PreviousPolicyNumber, "'", "", "ALL")>
		<cfset form.PolicyEffectiveDate = DateFormat(qryExcel.PolicyEffectiveDate, "mm/dd/yyyy")>
		<cfset form.PolicyExpirationDate = DateFormat(qryExcel.PolicyExpirationDate, "mm/dd/yyyy")>
		<cfset form.PolicyRetroactiveDate = DateFormat(qryExcel.PolicyRetroactiveDate, "mm/dd/yyyy")>
		<cfset form.NJSequenceNumber = qryExcel.NJSequenceNumber>
		<cfset form.PaymentPlanID = "">
		<cfloop query="GetPaymentPlans">
			<cfif CompareNoCase(GetPaymentPlans.PaymentPlan, qryExcel.PayPlan) EQ 0>
				<cfset form.PaymentPlanID = GetPaymentPlans.PaymentPlanID>
			</cfif>
		</cfloop>
		<cfset form.CoverageBasis = qryExcel.CoverageBasis>
		<cfif isDefined("qryExcel.ChargeType1")>
			<cfset form.ChargeType1 = qryExcel.ChargeType1>
		</cfif>
		<cfif isDefined("qryExcel.Amount1")>
			<cfset form.Amount1 = qryExcel.Amount1>
		</cfif>
		<cfif isDefined("qryExcel.ChargeType2")>
			<cfset form.ChargeType2 = qryExcel.ChargeType2>
		</cfif>
		<cfif isDefined("qryExcel.Amount2")>
			<cfset form.Amount2 = qryExcel.Amount2>
		</cfif>
		<cfif isDefined("qryExcel.ChargeType3")>
			<cfset form.ChargeType3 = qryExcel.ChargeType3>
		</cfif>
		<cfif isDefined("qryExcel.Amount3")>
			<cfset form.Amount3 = qryExcel.Amount3>
		</cfif>
		<cfif isDefined("qryExcel.ChargeType4")>
			<cfset form.ChargeType4 = qryExcel.ChargeType4>
		</cfif>
		<cfif isDefined("qryExcel.Amount4")>
			<cfset form.Amount4 = qryExcel.Amount4>
		</cfif>
		<cfif isDefined("qryExcel.ChargeType5")>
			<cfset form.ChargeType5 = qryExcel.ChargeType5>
		</cfif>
		<cfif isDefined("qryExcel.Amount5")>
			<cfset form.Amount5 = qryExcel.Amount5>
		</cfif>



		<!--- Set defaults --->
		<cfif Len(Trim(form.Surcharge)) EQ 0>
			<cfset form.Surcharge = 0>
		</cfif>
		<cfif Len(Trim(form.KyCollectionFee)) EQ 0>
			<cfset form.KyCollectionFee = 0>
		</cfif>
		<cfif Len(Trim(form.KyMunicipalTax)) EQ 0>
			<cfset form.KyMunicipalTax = 0>
		</cfif>
		<cfif Len(Trim(form.DeductibleAmountPerClaim)) EQ 0>
			<cfset form.DeductibleAmountPerClaim = 0>
		</cfif>
		<cfif Len(Trim(form.DeductibleAmountAggregate)) EQ 0>
			<cfset form.DeductibleAmountAggregate = 0>
		</cfif>
		<cfif Len(Trim(form.PreviousPolicyNumber)) EQ 0>
			<cfset form.PreviousPolicyNumber = "000000000">
		</cfif>
		<cfloop from="1" to="5" index="cnt">
			<cfif Len(Trim(form["ChargeType#cnt#"])) EQ 0>
				<cfset form["ChargeType#cnt#"] = "">
			</cfif>
			<cfif Len(Trim(form["Amount#cnt#"])) EQ 0>
				<cfset form["Amount#cnt#"] = "">
			</cfif>
		</cfloop>


		<!--- Determine ClientID --->
		<cfinclude template="QRY/QRY_GetClientByPolicyNumber.cfm">
		<cfif GetClientByPolicyNumber.RecordCount EQ 1>
			<cfset form.ClientID = GetClientByPolicyNumber.ClientID>
			<cfset variables.ClientID = GetClientByPolicyNumber.ClientID>
		<cfelse>
			<cfset form.ClientID = 0>
			<cfset variables.ClientID = 0>
		</cfif>

		<!--- Determine InsuranceCompanyID --->
		<cfloop query="GetInsuranceCompanies">
			<cfif CompareNoCase(GetInsuranceCompanies.InsuranceCompany, qryExcel.InsuranceCompany) EQ 0>
				<cfset form.InsuranceCompanyID = GetInsuranceCompanies.InsuranceCompanyID>
			</cfif>
		</cfloop>
<!---
		<cfset form.InsuranceCompanyID = stSystemConstants.insuranceCompanyID>
--->


		<!--- Determine PolicyModuleNumber --->
		<cfinclude template="QRY/QRY_GetTransactionsByClientID.cfm">
		<cfif form.TransactionCodeID EQ 1>
			<cfset form.PolicyModuleNumber = 0>
		<cfelseif form.TransactionCodeID EQ 2>
			<cfif GetTransactionsByClientID.RecordCount EQ 0>
				<cfset form.PolicyModuleNumber = 0>
			<cfelse>
				<cfset form.PolicyModuleNumber = GetTransactionsByClientID.PolicyModuleNumber + 1>
			</cfif>
		<cfelse>
			<cfif GetTransactionsByClientID.RecordCount EQ 0>
				<cfset form.PolicyModuleNumber = 0>
			<cfelse>
				<cfset form.PolicyModuleNumber = GetTransactionsByClientID.PolicyModuleNumber>
			</cfif>
		</cfif>


		<!--- If transaction is a cancellation and PolicyExpirationDate, TransactionEffectiveDate and TransactionExpiration dates are all the same, try to get original Policy Expiration Date from Transactions table --->
		<cfif (ListFind("7,8,9", form.TransactionCodeID) NEQ 0) AND (DateDiff("d", FORM.TransactionEffectiveDate, FORM.TransactionExpirationDate) EQ 0) AND (DateDiff("d", FORM.TransactionEffectiveDate, FORM.PolicyExpirationDate) EQ 0)>
			<!--- Get most recent new/renewal for this policy number --->
			<cfset variables.PolicyNumber = form.PolicyNumber>
			<cfinclude template="QRY/QRY_GetRecentNewOrRenewalPolicy.cfm">

			<!--- If found, update dates from query results --->
			<cfif GetRecentNewOrRenewalPolicy.RecordCount EQ 1>
				<cfset form.PolicyExpirationDate = DateFormat(GetRecentNewOrRenewalPolicy.PolicyExpirationDate, "mm/dd/yyyy")>
				<cfset form.TransactionExpirationDate = form.PolicyExpirationDate>
			</cfif>
		</cfif>


		<!--- Validate current record --->
		<cfinclude template="ERR/ERR_dataEntryAction.cfm">

		<!--- If errors, add to struct --->
		<cfif cntErrors NEQ 0>
			<cfset errors[ctr] = StructNew()>
			<cfset errors[ctr].cntErrors = cntErrors>
			<cfset errors[ctr].arrErrors = arrErrors>

			<cfset errorInd = true>
		</cfif>
	</cfif>
</cfloop>


<!--- If errors, redisplay form --->
<cfif errorInd>
	<cfinclude template="import.cfm">
<cfelse>
	<cftransaction>
	<cfloop query="qryExcel">
		<!--- Make sure row isn't blank --->
		<cfif Len(Trim( qryExcel.LastName & qryExcel.FirstName & qryExcel.BusinessName & qryExcel.Address & qryExcel.City & qryExcel.State )) NEQ 0>

			<!--- Reset variables --->
			<cfset form.ClientID = "">
			<cfset form.LastName = "">
			<cfset form.FirstName = "">
			<cfset form.MiddleInitial = "">
			<cfset form.BusinessName = "">
			<cfset form.Address = "">
			<cfset form.City = "">
			<cfset form.StateID = "">
			<cfset variables.Abbreviation = qryExcel.State>
			<cfset variables.State = "">
			<cfset form.ZipCode = "">
			<cfset form.FEIN = "">
			<cfset form.TransactionCodeID = "">
			<cfset form.TransactionEffectiveDate = "">
			<cfset form.TransactionExpirationDate = "">
			<cfset form.GrossPremium = "">
			<cfset form.KyCollectionFee = "">
			<cfset form.KyMunicipalTax = "">
			<cfset form.LimitAmountPerClaim = "">
			<cfset form.LimitAmountAggregate = "">
			<cfset form.DeductibleAmountPerClaim = "">
			<cfset form.DeductibleAmountAggregate = "">
			<cfset form.CoverageSymbol = "">
			<cfset form.PolicyNumber = "">
			<cfset form.PolicyModuleNumber = "0">
			<cfset form.PreviousPolicyNumber = "">
			<cfset form.PolicyEffectiveDate = "">
			<cfset form.PolicyExpirationDate = "">
			<cfset form.PolicyRetroactiveDate = "">
			<cfset form.InsuranceCompanyID = "">
			<cfset form.NJSequenceNumber = "">
			<cfset form.PaymentPlanID = "">
			<cfset form.CoverageBasis = "">
			<cfset form.ChargeType1 = "">
			<cfset form.Amount1 = "">
			<cfset form.ChargeType2 = "">
			<cfset form.Amount2 = "">
			<cfset form.ChargeType3 = "">
			<cfset form.Amount3 = "">
			<cfset form.ChargeType4 = "">
			<cfset form.Amount4 = "">
			<cfset form.ChargeType5 = "">
			<cfset form.Amount5 = "">


			<!--- Set variables based on contents of current excel record --->
			<cfset form.LastName = Trim(ReplaceNoCase(qryExcel.LastName, ", M.D.", "", "ALL"))>
			<cfset form.FirstName = Trim(qryExcel.FirstName)>
			<cfset form.MiddleInitial = Trim(qryExcel.MiddleName)>
			<cfset form.BusinessName = qryExcel.BusinessName>
			<cfset form.Address = qryExcel.Address>
			<cfset form.City = qryExcel.City>
			<cfset form.StateID = states[qryExcel.State]>
			<cfset variables.Abbreviation = qryExcel.State>
			<cfset variables.State = "">
			<cfset form.ZipCode = Replace(qryExcel.Zip, "'", "", "ALL")>
			<cfset form.FEIN = qryExcel.FEIN>
			<cfloop query="GetTransactionCodes">
				<cfif CompareNoCase(GetTransactionCodes.AmsCode, Left(qryExcel.TransactionCode, Len(GetTransactionCodes.AmsCode))) EQ 0>
					<cfset form.TransactionCodeID = GetTransactionCodes.TransactionCodeID>
				</cfif>
			</cfloop>
			<cfset form.TransactionEffectiveDate = DateFormat(qryExcel.TransactionEffectiveDate, "mm/dd/yyyy")>
			<cfset form.TransactionExpirationDate = DateFormat(qryExcel.TransactionExpirationDate, "mm/dd/yyyy")>
			<cfset form.GrossPremium = qryExcel.GrossPremium>
			<cfset form.KyCollectionFee = qryExcel.KyCollectionFee>
			<cfset form.KyMunicipalTax = qryExcel.KyMunicipalTax>
			<cfset form.LimitAmountPerClaim = Replace(qryExcel.LimitAmountPerClaim, ",", "", "ALL")>
			<cfset form.LimitAmountAggregate = Replace(qryExcel.LimitAmountAggregate, ",", "", "ALL")>
			<cfset form.DeductibleAmountPerClaim = Replace(DeductibleAmountPerClaim, ",", "", "ALL")>
			<cfset form.DeductibleAmountAggregate = Replace(qryExcel.DeductibleAmountAggregate, ",", "", "ALL")>
			<cfset form.CoverageSymbol = qryExcel.CoverageSymbol>
			<cfset form.PolicyNumber = Replace(qryExcel.PolicyNumber, "'", "", "ALL")>
			<cfset form.PreviousPolicyNumber = Replace(qryExcel.PreviousPolicyNumber, "'", "", "ALL")>
			<cfset form.PolicyEffectiveDate = DateFormat(qryExcel.PolicyEffectiveDate, "mm/dd/yyyy")>
			<cfset form.PolicyExpirationDate = DateFormat(qryExcel.PolicyExpirationDate, "mm/dd/yyyy")>
			<cfset form.PolicyRetroactiveDate = DateFormat(qryExcel.PolicyRetroactiveDate, "mm/dd/yyyy")>
			<cfset form.NJSequenceNumber = qryExcel.NJSequenceNumber>
			<cfloop query="GetPaymentPlans">
				<cfif CompareNoCase(GetPaymentPlans.PaymentPlan, qryExcel.PayPlan) EQ 0>
					<cfset form.PaymentPlanID = GetPaymentPlans.PaymentPlanID>
				</cfif>
			</cfloop>
			<cfset form.CoverageBasis = Left(qryExcel.CoverageBasis, 1)>
			<cfif isDefined("qryExcel.ChargeType1")>
				<cfset form.ChargeType1 = qryExcel.ChargeType1>
			</cfif>
			<cfif isDefined("qryExcel.Amount1")>
				<cfset form.Amount1 = qryExcel.Amount1>
			</cfif>
			<cfif isDefined("qryExcel.ChargeType2")>
				<cfset form.ChargeType2 = qryExcel.ChargeType2>
			</cfif>
			<cfif isDefined("qryExcel.Amount2")>
				<cfset form.Amount2 = qryExcel.Amount2>
			</cfif>
			<cfif isDefined("qryExcel.ChargeType3")>
				<cfset form.ChargeType3 = qryExcel.ChargeType3>
			</cfif>
			<cfif isDefined("qryExcel.Amount3")>
				<cfset form.Amount3 = qryExcel.Amount3>
			</cfif>
			<cfif isDefined("qryExcel.ChargeType4")>
				<cfset form.ChargeType4 = qryExcel.ChargeType4>
			</cfif>
			<cfif isDefined("qryExcel.Amount4")>
				<cfset form.Amount4 = qryExcel.Amount4>
			</cfif>
			<cfif isDefined("qryExcel.ChargeType5")>
				<cfset form.ChargeType5 = qryExcel.ChargeType5>
			</cfif>
			<cfif isDefined("qryExcel.Amount5")>
				<cfset form.Amount5 = qryExcel.Amount5>
			</cfif>


			<!--- Check for Cook County --->
			<cfif ( (CompareNoCase(qryExcel.State, "IL") EQ 0) AND (CompareNoCase(form.City, "Chicago") EQ 0) ) AND ( (CompareNoCase(qryExcel.County, "Cook") EQ 0) OR (CompareNoCase(qryExcel.County, "Cook County") EQ 0) )>
				<cfset form.CookCountyInd = 1>
			<cfelse>
				<cfset form.CookCountyInd = 0>
			</cfif>

			<!--- Set defaults --->
			<cfif Len(Trim(form.Surcharge)) EQ 0>
				<cfset form.Surcharge = 0>
			</cfif>
			<cfif Len(Trim(form.KyCollectionFee)) EQ 0>
				<cfset form.KyCollectionFee = 0>
			</cfif>
			<cfif Len(Trim(form.KyMunicipalTax)) EQ 0>
				<cfset form.KyMunicipalTax = 0>
			</cfif>
			<cfif Len(Trim(form.DeductibleAmountPerClaim)) EQ 0>
				<cfset form.DeductibleAmountPerClaim = 0>
			</cfif>
			<cfif Len(Trim(form.DeductibleAmountAggregate)) EQ 0>
				<cfset form.DeductibleAmountAggregate = 0>
			</cfif>
			<cfif Len(Trim(form.PreviousPolicyNumber)) EQ 0>
				<cfset form.PreviousPolicyNumber = "000000000">
			</cfif>

			<!--- Determine ClientID --->
			<cfinclude template="QRY/QRY_GetClientByPolicyNumber.cfm">
			<cfif GetClientByPolicyNumber.RecordCount EQ 1>
				<cfset form.ClientID = GetClientByPolicyNumber.ClientID>
				<cfset variables.ClientID = GetClientByPolicyNumber.ClientID>
			<cfelse>
				<cfinclude template="QRY/QRY_GetMaxClientID.cfm">
				<cfif Len(Trim(variables.MaxClientID)) EQ 0>
					<cfset form.ClientID = 1>
					<cfset variables.ClientID = 1>
				<cfelse>
					<cfset form.ClientID = variables.MaxClientID + 1>
					<cfset variables.ClientID = variables.MaxClientID + 1>
				</cfif>
			</cfif>

			<!--- Determine InsuranceCompanyID --->
			<cfloop query="GetInsuranceCompanies">
				<cfif CompareNoCase(GetInsuranceCompanies.InsuranceCompany, qryExcel.InsuranceCompany) EQ 0>
					<cfset form.InsuranceCompanyID = GetInsuranceCompanies.InsuranceCompanyID>
				</cfif>
			</cfloop>
<!---
			<cfset form.InsuranceCompanyID = stSystemConstants.insuranceCompanyID>
--->


			<!--- Determine PolicyModuleNumber --->
			<cfinclude template="QRY/QRY_GetTransactionsByClientID.cfm">
			<cfif form.TransactionCodeID EQ 1>
				<cfset form.PolicyModuleNumber = 0>
			<cfelseif form.TransactionCodeID EQ 2>
				<cfif GetTransactionsByClientID.RecordCount EQ 0>
					<cfset form.PolicyModuleNumber = 0>
				<cfelse>
					<cfset form.PolicyModuleNumber = GetTransactionsByClientID.PolicyModuleNumber + 1>
				</cfif>
			<cfelse>
				<cfif GetTransactionsByClientID.RecordCount EQ 0>
					<cfset form.PolicyModuleNumber = 0>
				<cfelse>
					<cfset form.PolicyModuleNumber = GetTransactionsByClientID.PolicyModuleNumber>
				</cfif>
			</cfif>


			<!--- If transaction is a cancellation and PolicyExpirationDate, TransactionEffectiveDate and TransactionExpiration dates are all the same, try to get original Policy Expiration Date from Transactions table --->
			<cfif (ListFind("7,8,9", form.TransactionCodeID) NEQ 0) AND (DateDiff("d", FORM.TransactionEffectiveDate, FORM.TransactionExpirationDate) EQ 0) AND (DateDiff("d", FORM.TransactionEffectiveDate, FORM.PolicyExpirationDate) EQ 0)>
				<!--- Get most recent new/renewal for this policy number --->
				<cfset variables.PolicyNumber = form.PolicyNumber>
				<cfinclude template="QRY/QRY_GetRecentNewOrRenewalPolicy.cfm">

				<!--- If found, update dates from query results --->
				<cfif GetRecentNewOrRenewalPolicy.RecordCount EQ 1>
					<cfset form.PolicyExpirationDate = DateFormat(GetRecentNewOrRenewalPolicy.PolicyExpirationDate, "mm/dd/yyyy")>
					<cfset form.TransactionExpirationDate = form.PolicyExpirationDate>
				</cfif>
			</cfif>


			<!--- Determine Installment Schedule --->
			<cfif (CompareNoCase(qryExcel.PayPlan, "Full Pay") EQ 0) OR (form.TransactionCodeID GT 2)>
				<!--- If pay plan is "Full Pay" or transaction is "New Business" or "Renewal", single installment --->
				<cfset form.InstallmentTotalNum = 1>
				<cfset form.InstallmentPaidNum = 0>
				<cfset form.InstallmentDates = "">
				<cfset form.InstallmentAmounts = "">
				<cfset form.PaymentPlanID = 1>
			<cfelse>
				<!--- If pay plan is "Installment" or transaction is anything other than "New Business" or "Renewal", multiple installments installment --->
				<cfset form.InstallmentPaidNum = 0>
				<cfset form.InstallmentDates = "">
				<cfset form.InstallmentAmounts = "">

				<!--- Calculate down payment: 30% of GrossPremium + 100% of KY fees and Surplus --->
				<cfset variables.InstallmentPaymentTotal = form.GrossPremium + form.KyMunicipalTax + form.KyCollectionFee + form.Surcharge>
				<cfset variables.InstallmentDownPayment = RoundPlus2(form.GrossPremium * 0.30) + form.KyMunicipalTax + form.KyCollectionFee + form.Surcharge>
				<cfset variables.InstallmentPaymentBalance = variables.InstallmentPaymentTotal - variables.InstallmentDownPayment>
				<cfset variables.InstallmentPaymentSubTotal = 0>

				<!--- Determine number of installments --->
				<cfif CompareNoCase(qryExcel.PayPlan, "30% DP, 3 Bi-mthly pmts") EQ 0>
					<cfset form.InstallmentTotalNum = 4>
				<cfelseif CompareNoCase(qryExcel.PayPlan, "30% DP, 4 Bi-mthly pmts") EQ 0>
					<cfset form.InstallmentTotalNum = 5>
				</cfif>

				<!--- Initialize date of first payment --->
				<cfset variables.InstallmentStartDate = DateFormat(form.PolicyEffectiveDate, "mm/dd/yyyy")>

				<!--- Calculate Installments --->
				<cfloop from="1" to="#form.InstallmentTotalNum#" index="variables.Installment">
					<!--- Determine installment amount --->
					<cfif variables.Installment EQ 1>
						<!--- First installment, payment = down payment --->
						<cfset variables.InstallmentAmount = variables.InstallmentDownPayment>
						<cfset variables.InstallmentPaymentSubTotal = variables.InstallmentDownPayment>
					<cfelseif variables.Installment EQ form.InstallmentTotalNum>
						<cfset variables.InstallmentAmount = variables.InstallmentPaymentTotal - variables.InstallmentPaymentSubTotal>
						<cfset variables.InstallmentPaymentSubTotal = variables.InstallmentPaymentSubTotal + variables.InstallmentAmount>
					<cfelse>
						<cfset variables.InstallmentAmount = RoundPlus2(variables.InstallmentPaymentBalance / (form.InstallmentTotalNum - 1))>
						<cfset variables.InstallmentPaymentSubTotal = variables.InstallmentPaymentSubTotal + variables.InstallmentAmount>
					</cfif>

					<!--- Determine installment date --->
					<cfset variables.InstallmentDate = DateAdd("m", ((variables.Installment - 1) * 2), variables.InstallmentStartDate)>

					<!--- Build installment date/amount lists --->
					<cfset form.InstallmentDates = ListAppend(form.InstallmentDates, DateFormat(variables.InstallmentDate, "mm/dd/yyyy"))>
					<cfset form.InstallmentAmounts = ListAppend(form.InstallmentAmounts, variables.InstallmentAmount)>
				</cfloop>
			</cfif>



			<!--- Get Risk Location Code --->
			<cfinclude template="BIZ/BIZ_GetRiskLocationCode.cfm">

			<!--- Skip entries with a premium equal to zero --->
			<cfif form.GrossPremium NEQ 0>
				<!--- Add transaction to database --->
				<cfinclude template="QRY/QRY_AddTransaction.cfm">

				<!--- Add transaction surcharges to database --->
				<cfloop from="1" to="5" index="cnt">
					<!--- If surcharge is not empty --->
					<cfif (Len(Trim(form["chargeType#cnt#"])) NEQ 0) AND (form["amount#cnt#"] NEQ 0)>
						<!--- Get surcharge details --->
						<cfset variables.surcharge = Trim(form["chargeType#cnt#"])>
						<cfinclude template="QRY/QRY_GetStateSurcharge.cfm">

						<!--- Check if current charge type is valid for current state --->
						<cfif (GetStateSurcharge.RecordCount NEQ 0) AND (GetStateSurcharge.StateID EQ form.StateID)>
							<!--- Add to database --->
							<cfset variables.SurchargeID = GetStateSurcharge.SurchargeID>
							<cfset variables.SurchargeAmount = form["amount#cnt#"]>
							<cfinclude template="QRY/QRY_AddTransactionSurcharge.cfm">
						</cfif>
					</cfif>
				</cfloop>

				<!--- Maintain legacy data tables --->
				<cfinclude template="BIZ/BIZ_MaintainLegacyData.cfm">
			</cfif>
		</cfif>
	</cfloop>
	</cftransaction>

	<!--- Redirect to confirmation screen --->
	<cflocation url="importConfirmed.cfm" addtoken="No">
</cfif>


