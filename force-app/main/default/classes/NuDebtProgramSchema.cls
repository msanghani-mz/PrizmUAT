/**
 * @File Name          : NuDebtProgramSchema.cls
 * @Description        : 
 * @Author             : anmol@fsDev
 * @Group              : 
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/13/2020   anmol@fsDev     Initial Version
**/
//DV-541 new class created
public class NuDebtProgramSchema {
    
    public class NuDebtProgramRequest{
        public String program_Id                    {get;set;} 
        public String DNL_Status                    {get;set;} 
        public Decimal Estimated_Loan_Amount         {get;set;}//DV-541
        public Decimal Estimated_Financed_Amount     {get;set;}//DV-541
        public Decimal Estimated_Number_of_Payments  {get;set;}//DV-541
        public String Loan_Repayment_Frequency       {get;set;}//DV-541
        public Date Estimated_Loan_Start_Date        {get;set;}//DV-541
        public String DNL_Application_Number		 {get;set;}//DV-593
        public String Underwriter 					 {get;set;}//DV-593
        public String Loan_Officer					 {get;set;}//DV-593
        public Decimal DNL_Term						 {get;set;}//DV-593
        public String DNL_Lending_Application_ID	 {get;set;}//DV-593
        public Date Pre_TILA_Signed_Date 			 {get;set;}//DV-593
        
        
        public List<TradelineRequest> tradelines {get; set;}
    }
    public class TradelineRequest{
        public String tradeline_Id                    {get;set;} 
        public Decimal DNL_Estimated_Settlement_Percentage         {get;set;}//DV-541
        public Decimal DNL_Estimated_Settlement_Amount     {get;set;}//DV-541
    }
     
    public class NuDebtProgramResponse{
        public string error_Message {get;set;} 
        public boolean is_success {get;set;} 
        /*NuDebtProgramResponse (){
            error_Message = null;
            is_success = true;            
        }*/
        //public String program_Id                   {get;set;} 
        //public String DNL_Status                   {get;set;} 
    }     
    
}