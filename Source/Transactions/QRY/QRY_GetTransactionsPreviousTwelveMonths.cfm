<!---
################################################################################
#
# Filename:		QRY_GetTransactionsPreviousTwelveMonths.cfm
#
# Description:	Retrieves transactions from the database
#
################################################################################
--->

<!--- Check for required variables --->
<cfparam name="variables.RangeStartDate" default="">
<cfparam name="variables.RangeEndDate" default="">
<cfparam name="variables.TransactionCodeID">
<cfparam name="variables.ExportTypeID" type="Numeric">
<cfparam name="variables.PositiveOnlyInd" type="Numeric">


<!--- Query database for transaction records --->
<cfquery name="GetTransactionsPreviousTwelveMonths" datasource="#stSiteDetails.DataSource#">
	SELECT
		TransactionID,
		PolicySymbol,
		PolicyNumber,
		PolicyModuleNumber,
		PreviousPolicyNumber,
		PolicyEffectiveDate,
		PolicyExpirationDate,
		FirstName,
		MiddleInitial,
		LastName,
		BusinessName,
		Address,
		City,
		aig2_xState.Abbreviation,
		aig2_xState.SurplusLinesLicenseNumber,
		ZipCode,
		ZipCode2,
		FEIN,
		TransactionEffectiveDate,
		TransactionExpirationDate,
		TransactionCodeID,
		GrossPremium,
		Surcharge,
		KyCollectionFee,
		KyMunicipalTax,
		LimitAmountPerClaim,
		LimitAmountAggregate,
		DeductibleAmountPerClaim,
		DeductibleAmountAggregate,
		CoverageSymbol,
		PolicyRetroactiveDate,
		InsuranceCompanyID,
		NjSequenceNumber,
		RiskLocationCode,
		PaymentPlanCode,
		PaymentPlan,
		CoverageBasis,
		InstallmentTotalNum,
		InstallmentPaidNum,
		InstallmentDates,
		InstallmentAmounts,
		CreationDateTime
	FROM
		aig2_xPaymentPlan
		INNER JOIN (aig2_xState
			INNER JOIN aig2_Transaction
				ON aig2_xState.StateID = aig2_Transaction.StateID)
			ON aig2_xPaymentPlan.PaymentPlanID = aig2_Transaction.PaymentPlanID
	WHERE
		(
			AccountsCurrentExportDateTime IS NULL
			OR  (
					PaymentPlanCode = '05'
					AND InstallmentPaidNum < InstallmentTotalNum
				)
		)
		<CFIF (Len(Trim(VARIABLES.RangeStartDate)) NEQ 0) AND (Len(Trim(VARIABLES.RangeEndDate)) NEQ 0)>
			AND (
					(
						PolicyEffectiveDate >= <CFQUERYPARAM CFSQLTYPE="CF_SQL_DATE" VALUE="#DateFormat(VARIABLES.RangeStartDate, 'mm/dd/yyyy')#">
						AND PolicyEffectiveDate <= <CFQUERYPARAM CFSQLTYPE="CF_SQL_DATE" VALUE="#DateFormat(VARIABLES.RangeEndDate, 'mm/dd/yyyy')#">
						AND TransactionCodeID IN (1,2)
					)
					OR
					(
						TransactionEffectiveDate >= <CFQUERYPARAM CFSQLTYPE="CF_SQL_DATE" VALUE="#DateFormat(VARIABLES.RangeStartDate, 'mm/dd/yyyy')#">
						AND TransactionEffectiveDate <= <CFQUERYPARAM CFSQLTYPE="CF_SQL_DATE" VALUE="#DateFormat(VARIABLES.RangeEndDate, 'mm/dd/yyyy')#">
						AND TransactionCodeID NOT IN (1,2)
					)
					OR
					(
						PaymentPlanCode = '05'
						AND InstallmentPaidNum < InstallmentTotalNum
					)
				)
		</CFIF>
	ORDER BY
		InsuranceCompanyID, TransactionEffectiveDate ASC
</cfquery>

