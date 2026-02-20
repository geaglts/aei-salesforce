@IsTest
public with sharing class ETC_TestProductModule {
    @IsTest
    static void productSchedule() {
        String cron = ETC_Utility.getCRONString('');
        Test.startTest();
        ETC_ScheduleGetProduct.start();
        ETC_ScheduleGetProduct scheduleProcess = new ETC_ScheduleGetProduct();
        System.schedule('TEST PRODUCTS SCHEDULE PROCESS', cron, scheduleProcess);
        Test.stopTest();
    }
}