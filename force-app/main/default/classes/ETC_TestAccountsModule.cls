@IsTest
public with sharing class ETC_TestAccountsModule {
    @IsTest
    static void login() {
        String cron = ETC_Utility.getCRONString('');
        Test.startTest();
        ETC_wsLoginSchedule.start();
        ETC_wsLoginSchedule scheduleProcess = new ETC_wsLoginSchedule();
        System.schedule('TEST LOGIN SCHEDULE PROCESS', cron, scheduleProcess);
        Test.stopTest();
    }
    
    @IsTest
    static void startSchedule() {
        String cron = ETC_Utility.getCRONString('');
        Test.startTest();
        ETC_GetAccountsSchedule.start();
        ETC_GetAccountsSchedule scheduleProcess = new ETC_GetAccountsSchedule();
        System.schedule('TEST ACCOUNT SCHEDULE PROCESS', cron, scheduleProcess);
        Test.stopTest();
    }

    @IsTest
    static void getSingleAccount() {
        Test.startTest();
        ETC_GetAccountsWs.getSingleAccount('TEST');
        Test.stopTest();
    }
}