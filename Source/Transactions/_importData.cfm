<!---
################################################################################
#
# Filename:		_importData.cfm
#
# Description:	Imports previously entered data from [AIG TRANSACTIONS] to aig2_Transaction
#
################################################################################
--->

<!--- Get previously entered transactions --->
<CFQUERY NAME="GetTransactions" DATASOURCE="#stSiteDetails.DataSource#">
	SELECT
		[CLIENTS_CLIENT ##] AS ClientID,
		[LAST NAME] AS LastName,
		[FIRST NAME] AS FirstName,
		[MI] AS MiddleInitial,
		[Business Name] AS BusinessName,
		[Insured Street Address] AS Address,
		[Insured City] AS City,
		[Insured State] AS State,
		[Insured ZIP] AS ZipCode,
		[Insured ZIP_4] AS ZipCode2,
		[Transaction Code] AS TransactionCodeID,
		[Trans Effective Date] AS TransactionEffectiveDate,
		[Trans Expiration Date] AS TransactionExpirationDate,
		[Gross Premium Sign] AS GrossPremiumSign,
		[Gross Premium Amount] AS GrossPremium,
		[Surcharge Sign] AS SurchargeSign,
		[Surcharge Amount] AS Surcharge,
		[KY Collection Fee Sign] AS KyCollectionFeeSign,
		[KY Collection Fee Amount] AS KyCollectionFee,
		[KY Municipal Tax Sign] AS KyMunicipalTaxSign,
		[KY Municipal Tax Amount] AS KyMunicipalTax,
		[Limit Amount Per Claim] AS LimitAmountPerClaim,
		[Limit Amount Aggregate] AS LimitAmountAggregate,
		[Deductible Amount Per Claim] AS DeductibleAmountPerClaim,
		[Deductible Amount Aggregate] AS DeductibleAmountAggregate,
		[Policy Symbol] AS PolicySymbol,
		[Policy Number] AS PolicyNumber,
		[Policy Module Number] AS PolicyModuleNumber,
		[Previous Policy Number] AS PreviousPolicyNumber,
		[Policy Effective Date] AS PolicyEffectiveDate,
		[Policy Expiration Date] AS PolicyExpirationDate,
		[Retroactive Date] AS PolicyRetroactiveDate
	FROM
		[AIG TRANSACTIONS]
</CFQUERY>


<!--- Get list of all states and convert to structure --->
<CFINCLUDE TEMPLATE="QRY/QRY_GetStates.cfm">
<CFSET VARIABLES.stStates = StructNew()>
<CFLOOP QUERY="GetStates">
	<CFSET VARIABLES.stStates[GetStates.Abbreviation] = GetStates.StateID>
</CFLOOP>



<CFLOOP QUERY="GetTransactions">
	<CFIF GetTransactions.GrossPremiumSign IS "-">
		<CFSET GrossPremium = GetTransactions.GrossPremium * -1>
	<CFELSE>
		<CFSET GrossPremium = GetTransactions.GrossPremium>
	</CFIF>

	<CFIF GetTransactions.SurchargeSign IS "-">
		<CFSET Surcharge = GetTransactions.Surcharge * -1>
	<CFELSE>
		<CFSET Surcharge = GetTransactions.Surcharge>
	</CFIF>

	<CFIF GetTransactions.KyCollectionFeeSign IS "-">
		<CFSET KyCollectionFee = GetTransactions.KyCollectionFee * -1>
	<CFELSE>
		<CFSET KyCollectionFee = GetTransactions.KyCollectionFee>
	</CFIF>

	<CFIF GetTransactions.KyMunicipalTaxSign IS "-">
		<CFSET KyMunicipalTax = GetTransactions.KyMunicipalTax * -1>
	<CFELSE>
		<CFSET KyMunicipalTax = GetTransactions.KyMunicipalTax>
	</CFIF>


	<!--- Insert transaction into database --->
	<CFQUERY NAME="AddTransaction" DATASOURCE="#stSiteDetails.DataSource#">
		INSERT INTO aig2_Transaction
		(
			ClientID,
			LastName,
			FirstName,
			MiddleInitial,
			BusinessName,
			Address,
			City,
			StateID,
			ZipCode,
			ZipCode2,
			TransactionCodeID,
			TransactionEffectiveDate,
			TransactionExpirationDate,
			GrossPremium,
			Surcharge,
			KyCollectionFee,
			KyMunicipalTax,
			LimitAmountPerClaim,
			LimitAmountAggregate,
			DeductibleAmountPerClaim,
			DeductibleAmountAggregate,
			PolicySymbol,
			PolicyNumber,
			PolicyModuleNumber,
			PreviousPolicyNumber,
			PolicyEffectiveDate,
			PolicyExpirationDate,
			PolicyRetroactiveDate,
			InsuranceCompanyID,
			CreationDateTime,
			PremiumCodingExportDateTime,
			AccountsCurrentExportDateTime
		)
		VALUES
		(
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_INTEGER" VALUE="#GetTransactions.ClientID#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#GetTransactions.LastName#" MAXLENGTH="255">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#GetTransactions.FirstName#" MAXLENGTH="255">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#GetTransactions.MiddleInitial#" MAXLENGTH="255" NULL="#IIf(Len(Trim(GetTransactions.MiddleInitial)) EQ 0, DE("Yes"), DE("No"))#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#GetTransactions.BusinessName#" MAXLENGTH="255" NULL="#IIf(Len(Trim(GetTransactions.BusinessName)) EQ 0, DE("Yes"), DE("No"))#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#GetTransactions.Address#" MAXLENGTH="35">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#GetTransactions.City#" MAXLENGTH="18">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_INTEGER" VALUE="#VARIABLES.stStates[GetTransactions.State]#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#GetTransactions.ZipCode#" MAXLENGTH="5">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#GetTransactions.ZipCode2#" MAXLENGTH="4">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_INTEGER" VALUE="#GetTransactions.TransactionCodeID#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_DATE" VALUE="#GetTransactions.TransactionEffectiveDate#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_DATE" VALUE="#GetTransactions.TransactionExpirationDate#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_MONEY" VALUE="#GrossPremium#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_MONEY" VALUE="#Surcharge#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_MONEY" VALUE="#KyCollectionFee#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_MONEY" VALUE="#KyMunicipalTax#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_MONEY" VALUE="#GetTransactions.LimitAmountPerClaim#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_MONEY" VALUE="#GetTransactions.LimitAmountAggregate#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_MONEY" VALUE="#GetTransactions.DeductibleAmountPerClaim#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_MONEY" VALUE="#GetTransactions.DeductibleAmountAggregate#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#GetTransactions.PolicySymbol#" MAXLENGTH="3">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_INTEGER" VALUE="#GetTransactions.PolicyNumber#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_INTEGER" VALUE="#GetTransactions.PolicyModuleNumber#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_INTEGER" VALUE="#GetTransactions.PreviousPolicyNumber#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_DATE" VALUE="#GetTransactions.PolicyEffectiveDate#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_DATE" VALUE="#GetTransactions.PolicyExpirationDate#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_DATE" VALUE="#GetTransactions.PolicyRetroactiveDate#">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_INTEGER" VALUE="029">,
			<CFQUERYPARAM CFSQLTYPE="CF_SQL_DATE" VALUE="#CreateODBCDateTime(Now())#">,
			NULL,
			NULL
		)
	</CFQUERY>
</CFLOOP>

