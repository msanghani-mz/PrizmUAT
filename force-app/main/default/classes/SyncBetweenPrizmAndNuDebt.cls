/**
 * @File Name          : SyncBetweenPrizmAndNuDeb.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/14/2019, 8:20:47 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/27/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class SyncBetweenPrizmAndNuDebt {

    //Static variable and global values for applicant to client. (Account Trigger)
    public static Boolean queryFieldMapping = TRUE;
    public static Boolean executeApplicantToClient = TRUE;
    public static Map<String,List<nu_dse__Field_mapping__c>> fieldMappingStaticMap =  new Map<String,List<nu_dse__Field_mapping__c>>();
    public static Set<Id> accIdSet = new Set<Id>();
    public static List<String> DataMappingNameList = new List<String>{'PrizmAccountToNuDebtAccount','PrizmAccountToNuDebtProgram', 
                                                            'NuDebtAccountToPrizmAccount', 'NuDebtProgramToPrizmAccount',
                                                            'PrizmCoClientAccountToNuDebtAccount',
                                                            'PrizmBankAccountToNuDebtBankAccount'};
    
    //Static variable and global values for client to applicant.
    public static Boolean executeClientToApplicant = TRUE;
    
    
    //Static variable and global values for program to applicant.
    public static Boolean executeNuDebtProgramToApplicant = TRUE;
    public static Set<Id> processorProgramIdSet = new Set<Id>();
    
    
    //Static variable and global values for prizm bank account  to nudebt bank account.
    public static Boolean isPrizmBAToNuDebtBA_FieldMappingQueried = FALSE;
    public static Set<Id> newfsCoreBankAccountIdSet = new Set<Id>();
    public static List<nu_dse__Field_mapping__c> nuDseFieldMappingList = new List<nu_dse__Field_mapping__c>(); 
    public static List<String> PrizmBAToNuDebtBA_dataMappingNamesList= new List<String>{'PrizmBankAccountToNuDebtBankAccount'};
    public static Boolean executePrizmBankAccountToNuDebtBankAccount = TRUE;
    
    
    //Static variable and global values for nudebt bank account  to prizm bank account.
    public static List<nu_dse__Field_Mapping__c> nuDebtBAToPrizmBAfieldMappingsList = new List<nu_dse__Field_Mapping__c>();
    public static Set<Id> nuDebtBankAccIdStaticSet = new Set<Id>();
    public static Boolean isNuDebtBAToPrizmBAFieldMappingQueried = FALSE;
    public static List<String> NudebtBAToPrizmBA_dataMappingNamesList = new List<String>{'NuDebtBankAccountToPrizmBankAccount'};
    public static Boolean executeNuDebtBankAccountToPrizmBankAccount = TRUE;
    
    
    //Static variable and global values for inbound payment  to nudebt payment.
    public static Set<Id> inbPaymentIdStaticSet = new Set<Id>();
    public static List<nu_dse__Field_Mapping__c> prizmToNuDebtfieldMappingsList = new List<nu_dse__Field_Mapping__c>();
    public static Boolean isPrizmToNuDebtFieldMappingQueried = FALSE;
    public static List<String> InbPaymentToNudebtPayment_dataMappingNamesList = new List<String>{'PrizmPaymentToNuDebtPayment'};
    public static Boolean executePrizmPaymentToNuDebtPayment = TRUE;
    
    //Static variable and global values for nudebt payment  to inbound payment.
    public static List<nu_dse__Field_Mapping__c> nuDebtToPrizmfieldMappingsList = new List<nu_dse__Field_Mapping__c>();
    public static Set<Id> nuDebtbPaymentIdStaticSet = new Set<Id>();
    public static Boolean isNuDebtToPrizmFieldMappingQueried = FALSE;
    public static List<String> NudebtPaymentToInbPayment_dataMappingNamesList = new List<String>{'NuDebtPaymentToPrizmPayment'};
    public static Boolean executeNuDebtPaymentToPrizmPayment = TRUE;
    
    //Static variable and global values for outbound payment  to nudebt payment.
    public static Set<Id> outbPaymentIdStaticSet = new Set<Id>();
    public static List<nu_dse__Field_Mapping__c> outbPaymentPrizmToNuDebtfieldMappingsList = new List<nu_dse__Field_Mapping__c>();
    public static Boolean isPrizmOutbPaymentToNuDebtFieldMappingQueried = FALSE;
    public static List<String> OutbPaymentToNudebtPayment_dataMappingNamesList = new List<String>{'PrizmOutboundPaymentToNuDebtPayment'};
    public static Boolean executePrizmOutbPaymentToNuDebtPayment = TRUE;
    
}