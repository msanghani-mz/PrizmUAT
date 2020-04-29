@isTest(seeAllData=false)
global class TestContractNotificationHelperData {
     global static fsServ__Contract_Direct_Debit__c getDirectDebit(fsServ__Lending_Contract__c pContract
                                                                   ,Map<Id,fsServ__Contract_Customer__c> pContractCustomerMap
                                                                   , Map<Id,fsCore__Bank_Account__c> pContractBankMap
                                                                   , Decimal pDebitAmount){
        

        fsServ__Contract_Direct_Debit__c poffPayment = getTestContractDirectDebit(pContract,pContractCustomerMap.get(pContract.Id),pContractBankMap.get(pContract.Id),'Fixed Amount',pDebitAmount);
        System.assertNotEquals(null, poffPayment);
        return poffPayment;
    }
     global static List<fsServ__Contract_Direct_Debit__c> getDirectDebits(List<fsServ__Lending_Contract__c> pContractList,Decimal pDebitAmount){
        
        List<fsServ__Contract_Direct_Debit__c> poffPayments = new List<fsServ__Contract_Direct_Debit__c>();
        Map<Id,fsServ__Contract_Customer__c> contractCustomerMap = getContractCustomer(pContractList);
        Map<Id,fsCore__Bank_Account__c> contractBankMap = getBankAccounts(pContractList);
        
        for(fsServ__Lending_Contract__c contract : pContractList){
            poffPayments.add(getDirectDebit(contract,contractCustomerMap,contractBankMap,pDebitAmount));
        }
          System.assertEquals(pContractList.size(), poffPayments.size(), 'New Direct Debit list size');
          return poffPayments;
     }
    
    public static fsServ__Contract_Direct_Debit__c getTestContractDirectDebit(
                                    fsServ__Lending_Contract__c pContract
                                  , fsServ__Contract_Customer__c pCustomer
                                  , fsCore__Bank_Account__c pBankAccount
                                  , String pDebitAmountSource
                                  , Decimal pDebitAmount){
        Map<String, RecordType> directDebitRecTypeMap
                = fsCore.RecordTypeUtil.getInstance()
                        .getRecordTypeMapByName(Schema.SObjectType.fsServ__Contract_Direct_Debit__c.getName());

        fsServ__Contract_Direct_Debit__c testDirectDebit = new fsServ__Contract_Direct_Debit__c();
        testDirectDebit.fsServ__Lending_Contract_Number__c = pContract.Id;
        testDirectDebit.RecordTypeId = directDebitRecTypeMap.get(fsCore.Constants.RECORD_TYPE_ACTIVE).Id;
        testDirectDebit.fsServ__Customer_Reference_Number__c =pCustomer.Id;
        testDirectDebit.fsServ__Bank_Account_Name__c = (pBankAccount != null ? pBankAccount.Id : null);
        testDirectDebit.fsServ__Debit_Amount_Source__c = pDebitAmountSource;
        testDirectDebit.fsServ__Debit_Amount__c = pDebitAmount;
        testDirectDebit.fsServ__Debit_Start_Date__c = System.today();
        testDirectDebit.fsServ__Next_Debit_Date__c = pContract.fsServ__Next_Payment_Due_Date__c;
        testDirectDebit.fsServ__Debit_Cycle__c = pContract.fsServ__Current_Payment_Cycle__c;
        
        System.assertNotEquals(null,testDirectDebit);
        return testDirectDebit;
    }    

    global static Map<Id,fsServ__Contract_Customer__c> getContractCustomer(List<fsServ__Lending_Contract__c> pContractList){
        Set<ID> contractIds = new Set<ID>();
        for(fsServ__Lending_Contract__c contract : pContractList){
          contractIds.add(contract.id);
        }
        List<fsServ__Contract_Customer__c> contractCustomerList =   [SELECT Id,fsServ__Contact_Name__c,fsServ__Lending_Contract_Number__c 
                                                                     FROM fsServ__Contract_Customer__c
                                                                     Where fsServ__Lending_Contract_Number__c = :contractIds];        

        Map<Id,fsServ__Contract_Customer__c> contractCustomerMap= new Map<Id,fsServ__Contract_Customer__c>();
        for(fsServ__Contract_Customer__c contractCustomer : contractCustomerList){
            contractCustomerMap.put(contractCustomer.fsServ__Lending_Contract_Number__c,contractCustomer);
        }

        return contractCustomerMap;
    }

    global static Map<Id,fsCore__Bank_Account__c> getBankAccounts(List<fsServ__Lending_Contract__c> pContractList){
         Set<ID> accountIds = new set<ID>();
         Set<ID> contactIds = new set<ID>();

         for (fsServ__Lending_Contract__c contract : pContractList){

              if (contract.fsServ__Primary_Customer_Account__c != null){
                  accountIds.add(contract.fsServ__Primary_Customer_Account__c);
              }
              if (contract.fsServ__Primary_Customer_Contact__c != null){
                  contactIds.add(contract.fsServ__Primary_Customer_Contact__c);
              }            
              
          }

        List<fsCore__Bank_Account__c> customerBankAccountList =   [SELECT Id,fsCore__Contact_Name__c
                                                                         ,fsCore__Account_Name__c
                                                                     FROM fsCore__Bank_Account__c
                                                                     Where (fsCore__Contact_Name__c IN :contactIds  OR 
                                                                            fsCore__Account_Name__c IN :accountIds)];



        Map<Id,fsCore__Bank_Account__c> contractBankAccountMap= new Map<Id,fsCore__Bank_Account__c>();
        for (fsServ__Lending_Contract__c contract : pContractList){
            for(fsCore__Bank_Account__c customerBankAccount : customerBankAccountList){
                if ((contract.fsServ__Primary_Customer_Contact__c == customerBankAccount.fsCore__Contact_Name__c)
                    ||(contract.fsServ__Primary_Customer_Account__c == customerBankAccount.fsCore__Account_Name__c)){
                    contractBankAccountMap.put(contract.id,customerBankAccount);
                }
                if ((contract.fsServ__Primary_Customer_Account__c != null) &&  (contract.fsServ__Primary_Customer_Contact__c != null)){
                    if ((contract.fsServ__Primary_Customer_Account__c == customerBankAccount.fsCore__Account_Name__c)
                        &&(contract.fsServ__Primary_Customer_Contact__c == customerBankAccount.fsCore__Contact_Name__c)){
                        contractBankAccountMap.put(contract.id,customerBankAccount);
                        break;
                    }
                }else if ((contract.fsServ__Primary_Customer_Account__c != null) &&  (contract.fsServ__Primary_Customer_Contact__c == null)){
                    if ((contract.fsServ__Primary_Customer_Account__c == customerBankAccount.fsCore__Account_Name__c)
                        &&(customerBankAccount.fsCore__Contact_Name__c == null)){
                        contractBankAccountMap.put(contract.id,customerBankAccount);
                        break;
                    }
                }else if ((contract.fsServ__Primary_Customer_Account__c == null) &&  (contract.fsServ__Primary_Customer_Contact__c != null)){
                    if ((contract.fsServ__Primary_Customer_Account__c == null)
                        &&(contract.fsServ__Primary_Customer_Contact__c == customerBankAccount.fsCore__Contact_Name__c)){
                        contractBankAccountMap.put(contract.id,customerBankAccount);
                        break;
                    }
                }
            }
        }   

      return contractBankAccountMap; 
    }
    
    global static fsServ__Contract_Payoff_Quote__c getTestPayoffQuotes(fsServ__Lending_Contract__c pContract, Date pPayoffDate){
       fsServ__Contract_Payoff_Quote__c payoffQuotes = getTestPayoffQuote(pContract,pPayoffDate);
        System.assertNotEquals(null,payoffQuotes);
        return payoffQuotes;
         }
             

      
    global static fsServ__Contract_Payoff_Quote__c getTestPayoffQuote(fsServ__Lending_Contract__c pContract
                                                            , Date pPayoffQuoteDate){
        fsServ__Contract_Payoff_Quote__c payoffQuote = new fsServ__Contract_Payoff_Quote__c();
        payoffQuote.fsServ__Lending_Contract_Number__c = pContract.Id;
        payoffQuote.fsServ__Request_Date__c = pPayoffQuoteDate;
        payoffQuote.fsServ__Request_Valid_Until_Date__c = pPayoffQuoteDate;
        payoffQuote.fsServ__Latest_Interest_Accrual_Date__c = pContract.fsServ__Latest_Interest_Accrual_Date__c;
        
        Integer daysDiff = pContract.fsServ__Latest_Interest_Accrual_Date__c.daysBetween(pPayoffQuoteDate);
        daysDiff = (daysDiff < 0 ? 0 : daysDiff);
        
        Decimal interestAccrual = ((pContract.fsServ__Total_Outstanding_Amount__c * pContract.fsServ__Current_Rate__c/100) * daysDiff/365);
        interestAccrual = interestAccrual.setScale(2);
        
        payoffQuote.fsServ__Payoff_Amount_Calculated__c = pContract.fsServ__Total_Outstanding_Amount__c + interestAccrual;
        payoffQuote.fsServ__Interest_Per_Day_Amount__c = (daysDiff <= 0 ? 0 : ((interestAccrual / daysDiff).setScale(2)));
        
        System.assertNotEquals(null, payoffQuote);
        return payoffQuote;
    }
    
    global static fsServ__Contract_Due__c getTestContractDue(fsServ__Lending_Contract__c pContract,Date pPaymentDate){
        fsServ__Contract_Due__c duePayments = new fsServ__Contract_Due__c();
        duepayments.fsServ__Lending_Contract_Number__c = pContract.Id;
        duePayments.fsServ__Due_Date__c=pPaymentDate;
        duePayments.fsServ__Due_Amount__c=pContract.fsServ__Next_Payment_Due_Amount__c;
        duePayments.fsServ__Transaction_Date__c=System.Today();
        duePayments.fsServ__Is_Active__c=true;
        System.assertNotEquals(null,duePayments);
        return duePayments;
        
    }
     global static fsServ__Contract_Due__c getDuePayment(fsServ__Lending_Contract__c pContract
                                                                        , Date pDueDate){
        

       fsServ__Contract_Due__c duePayment = getTestContractDue(pContract,pDueDate);
        System.assertNotEquals(null, duePayment);
        return duePayment;
    }


}