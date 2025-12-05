public with sharing class DiscountValidator {

    @AuraEnabled
    public static DiscountResult validateDeal(Id oppId, Decimal discount) {

        User currentUser = [
            SELECT Id, Department
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        String department = currentUser.Department;

        if (String.isBlank(department)) {
            return new DiscountResult(
                'NO_DEPARTMENT',
                'Owner department is not defined on the Opportunity Owner.',
                false
            );
        }

        Map<String, Discount_Config__mdt> configs = Discount_Config__mdt.getAll();
        Discount_Config__mdt cfg = configs.get(department);

        if (cfg == null) {
            return new DiscountResult(
                'NO_CONFIG',
                'No discount configuration found for department: ' + department,
                false
            );
        }

        Decimal softCap = cfg.Soft_Cap_Percent__c;
        Decimal hardCap = cfg.Hard_Cap_Percent__c;

        if (discount > hardCap) {
            return new DiscountResult(
                'BLOCKED',
                'Discount exceeds hard cap (' + hardCap + '%). Not allowed.',
                false
            );
        }
        else if (discount > softCap) {
            return new DiscountResult(
                'APPROVAL_NEEDED',
                'Above soft cap (' + softCap + '%). Approval required.',
                true
            );
        }
        else {
            return new DiscountResult(
                'AUTO_APPROVED',
                'Within allowed discount limit.',
                true
            );
        }
    }
    
    @AuraEnabled
    public static String submitForApproval(Id oppId) {

    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setObjectId(oppId);
    Approval.ProcessResult result = Approval.process(req);

    if (!result.isSuccess()) {
        return 'Error: ' + result.getErrors()[0].getMessage();
    }

    return 'SUCCESS';
}


    public class DiscountResult {
    @AuraEnabled public String status;
    @AuraEnabled public String message;
    @AuraEnabled public Boolean allowed;

    public DiscountResult(String status, String message, Boolean allowed) {
        this.status = status;
        this.message = message;
        this.allowed = allowed;
    }
    }
}