@isTest
public with sharing class BuyProductTableControllerTest {
	@TestSetup
	static void makeData() {
		List<SObject> testData = new List<SObject>();
		Product_Table__c product = new Product_Table__c(
			Name = 'Soft Toy',
			Product_Description__c = 'So cool to squeeze, so perfect to sleep with!',
			Image_Url__c = 'https://sc01.alicdn.com/kf/HTB1JiascGLN8KJjSZFm763Q6XXar/free-sample-plush-dog-pillow-for-kids.png_300x300.jpg',
            Unit_Price__c = 20,
            Units_Available__c = 130
		);
        testData.add(product);
        Contact customerContact = new Contact(
			Email__c = 'testContactFromDb@test.test',
			FirstName = 'Test',
			LastName = 'Test'
		);
		testData.add(customerContact);
		insert testData;
	}
	@isTest 
	public static void buyProductForNewContactWithoutErrorsTest() {
		Product_Table__c product = [
			SELECT Id, Name, Unit_Price__c, Units_Available__c
			FROM Product_Table__c
            WHERE Name = 'Soft Toy'
			LIMIT 1
		];
		ApexPages.StandardController stdController = new ApexPages.StandardController(product);
		BuyProductTableController buyProductTableController = new BuyProductTableController(stdController);
		PageReference productTablePage = new PageReference(System.Label.PageReference_ProductTable);
		buyProductTableController.customerContact = new Contact(
			Email__c = 'test@test.test',
			FirstName = 'Test',
			LastName = 'Test'
		);
		List<Order_Table__c> orderList = [
			SELECT Id
			FROM Order_Table__c
			WHERE Product__c = :product.Id
		];
		System.assertEquals(0, orderList.size());
		List<Contact> contactList = [
			SELECT Id
			FROM Contact
			WHERE Email__c = 'test@test.test'
		];
		System.assertEquals(0, contactList.size());

		Test.startTest();
		buyProductTableController.unitCount = 50;
        Decimal actualTotalAmount = buyProductTableController.getTotalAmount();
        Decimal actualAvailableUnits = buyProductTableController.getUnitsAvailable();
		buyProductTableController.buyCurrentItem();
		Pagereference tablePage = buyProductTableController.backToProductTablePage();
		Test.stopTest();

		List<Contact> contactListAfterBuying = [
			SELECT Id
			FROM Contact
			WHERE Email__c = 'test@test.test'
		];
		List<Order_Table__c> orderListAfterBuying = [
			SELECT Id
			FROM Order_Table__c
			WHERE Product__c = :product.Id
		];

		System.assertEquals(1, orderListAfterBuying.size());
		System.assertEquals(1, contactListAfterBuying.size());
		System.assertEquals(productTablePage.getUrl(), tablePage.getUrl());
		System.assertEquals(product.Unit_Price__c * buyProductTableController.unitCount, actualTotalAmount);
		System.assertEquals(product.Units_Available__c - buyProductTableController.unitCount, actualAvailableUnits);
        System.assertEquals(System.Label.Order_Table_Confirm, buyProductTableController.confirmMessage);
        System.assertEquals(true, String.isBlank(buyProductTableController.errorMessage));
        System.assertEquals(true, String.isBlank(buyProductTableController.inputWarningMessage));
	}

    @isTest
    public static void buyProductForDbContactWithErrorTest() {
		Product_Table__c product = [
			SELECT Id, Name, Unit_Price__c, Units_Available__c
			FROM Product_Table__c
            WHERE Name = 'Soft Toy'
			LIMIT 1
		];
		ApexPages.StandardController stdController = new ApexPages.StandardController(product);
		BuyProductTableController buyProductTableController = new BuyProductTableController(stdController);
		PageReference productTablePage = new PageReference(System.Label.PageReference_ProductTable);
        String newLastName = 'New Last Name';
        String expectedWarningMessage = System.Label.Units_Available + ' ' + (Integer)product.Units_Available__c;
		buyProductTableController.customerContact = new Contact(
			Email__c = 'testContactFromDb@test.test',
			FirstName = 'Test',
			LastName = newLastName
		);

		Test.startTest();
		buyProductTableController.unitCount = 0;
        Decimal actualTotalAmount = buyProductTableController.getTotalAmount();
        Decimal actualAvailableUnits = buyProductTableController.getUnitsAvailable();
		buyProductTableController.buyCurrentItem();
		Test.stopTest();

		Contact contactAfterBuying = [
			SELECT Id, LastName
			FROM Contact
			WHERE Email__c = 'testContactFromDb@test.test'
            LIMIT 1
		];
		List<Order_Table__c> orderListAfterBuying = [
			SELECT Id
			FROM Order_Table__c
			WHERE Product__c = :product.Id
		];

        System.assertEquals(newLastName, contactAfterBuying.LastName);
		System.assertEquals(0, orderListAfterBuying.size());
		System.assertEquals(0, actualTotalAmount);
		System.assertEquals(product.Units_Available__c, actualAvailableUnits);
        System.assertEquals(true, String.isBlank(buyProductTableController.confirmMessage));
        System.assertEquals(true, String.isBlank(buyProductTableController.errorMessage));
        System.assertEquals(expectedWarningMessage, buyProductTableController.inputWarningMessage);
	}
}
