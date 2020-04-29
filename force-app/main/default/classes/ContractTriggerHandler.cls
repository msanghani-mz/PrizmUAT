/*
* Class Name   - ContractTriggerHandler
* Description  - Trigger Handler for ContractCustomTriggerManager
* Test Class   - ContractTriggerHandlerTest
*/
public class ContractTriggerHandler {
    
    /**************************************************************************
       Purpose: This method will be called from lending application trigger, after update
       Parameters: List- new values, Map- old values
       Returns: 
       Throws [Exceptions]: 
	****************************************************************************/
    public Static void updateFeeTemplate (List<fsServ__Lending_Contract__c> newContracts, Map<Id, fsServ__Lending_Contract__c> oldContractsMap){
        Set<String> primaryAccountIds = new Set<String>();
        Map<Id, fsServ__Lending_Contract__c> lendingContractByAccountId = new Map<Id, fsServ__Lending_Contract__c>();
        system.debug('++++newContracts+++++'+newContracts);
        for (fsServ__Lending_Contract__c newContract: newContracts) {
            fsServ__Lending_Contract__c oldContract = oldContractsMap.get(newContract.Id);
            if (newContract.Investor_Name__c != oldContract.Investor_Name__c && newContract.Investor_Name__c == 'Versara DNL WLoC') {
               
                primaryAccountIds.add(newContract.fsServ__Primary_Customer_Account__c);
                lendingContractByAccountId.put(newContract.fsServ__Primary_Customer_Account__c, newContract);
            }
        }
        system.debug('++++++primaryAccountIds++++'+primaryAccountIds);
        if(!primaryAccountIds.isEmpty()) {
            Map<String, nu_dse__Fee_Template__c> feeTemplateMap = new Map<String, nu_dse__Fee_Template__c>();
            List<nu_dse__Program__c> programToUpdate = new List<nu_dse__Program__c>();
            List<nu_dse__Fee_Template__c> feeTemplates = [Select Id, Name, nu_dse__GCS_Fee_Group_Id__c, nu_dse__RAMS_Fee_Group_Id__c From nu_dse__Fee_Template__c];
            for (nu_dse__Fee_Template__c feeTemplate: feeTemplates) {
                feeTemplateMap.put(feeTemplate.Name, feeTemplate);    
            }

            List<nu_dse__Program__c> nudebtAccountRelatedPrograms = [Select Id, Name, nu_dse__Account__c, nu_dse__Fee_Template__c, nu_dse__Processor__c, nu_dse__Processor__r.Name from nu_dse__Program__c where nu_dse__Account__c IN :primaryAccountIds];
            system.debug('++++++nudebtAccountRelatedPrograms++++'+nudebtAccountRelatedPrograms);
            system.debug('++++++feeTemplateMap++++'+feeTemplateMap);
            for (nu_dse__Program__c nudebtProgram: nudebtAccountRelatedPrograms) {
                fsServ__Lending_Contract__c contractRelatedToProgram = lendingContractByAccountId.get(nudebtProgram.nu_dse__Account__c);
                if (contractRelatedToProgram.Application_Payment_Processor_Name__c == 'CFT') {
                    nudebtProgram.nu_dse__Lender_Name__c = 'Versara DST 2019-2 Trust';
                    programToUpdate.add(nudebtProgram);
                } else if (contractRelatedToProgram.Application_Payment_Processor_Name__c == 'RAM') {
                    nu_dse__Fee_Template__c feeTemplate = feeTemplateMap.get('RAM Versara - WLoC1');
                    nudebtProgram.nu_dse__Fee_Template__c = feeTemplate.Id;                     
                    programToUpdate.add(nudebtProgram);
                } else if (contractRelatedToProgram.Application_Payment_Processor_Name__c == 'GCS') {
                    if (contractRelatedToProgram.Debt_Resolution_Program_Name__c == 'Timberline') {
                        nu_dse__Fee_Template__c feeTemplate = feeTemplateMap.get('GCS Versara - Timberline - WLoC1');
                        nudebtProgram.nu_dse__Fee_Template__c = feeTemplate.Id; 
                        nudebtProgram.nu_dse__GCS_Fee_Group_Id__c = feeTemplate.nu_dse__GCS_Fee_Group_Id__c;
                        programToUpdate.add(nudebtProgram);
                    } else {
                        nu_dse__Fee_Template__c feeTemplate = feeTemplateMap.get('GCS Versara - WLoC1');
                        nudebtProgram.nu_dse__Fee_Template__c = feeTemplate.Id; 
                        nudebtProgram.nu_dse__GCS_Fee_Group_Id__c = feeTemplate.nu_dse__GCS_Fee_Group_Id__c;
                        programToUpdate.add(nudebtProgram);
                    }
                }
            }
            if (!programToUpdate.isEmpty()) {
                update programToUpdate;
            }
        }
    }
}