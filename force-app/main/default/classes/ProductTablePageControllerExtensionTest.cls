@isTest
public with sharing class ProductTablePageControllerExtensionTest {

	@TestSetup
	static void makeData() {
		List<SObject> testData = new List<SObject>();
		Product_Table__c product = new Product_Table__c(
			Name = 'Soft Toy',
			Product_Description__c = 'So cool to squeeze, so perfect to sleep with!',
			Image_Url__c = 'https://sc01.alicdn.com/kf/HTB1JiascGLN8KJjSZFm763Q6XXar/free-sample-plush-dog-pillow-for-kids.png_300x300.jpg'
		);
		testData.add(product);
		insert testData;
	}
	@isTest 
	public static void pageControllerExtensionTest() {
		List<Product_Table__c> productList = [
			SELECT Id
			FROM Product_Table__c
		];
		ApexPages.StandardController stdController = new ApexPages.StandardController(productList[0]);
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(productList);
		ProductTablePageControllerExtension productTableController = new ProductTablePageControllerExtension(stdController);
		ProductTablePageControllerExtension ProductTableListController = new ProductTablePageControllerExtension(stdSetController);
		productTableController.currentProductTableId = productList[0].Id;
		PageReference buyProductTablePage = new PageReference(System.Label.PageReference_BuyCurrentProductTable);
		PageReference currentProductPage = new PageReference(System.Label.PageReference_CurrentProductTable);
		PageReference productTablePage = new PageReference(System.Label.PageReference_ProductTable);

		Test.startTest();
		Pagereference tablePage = productTableController.backToProductTablePage();
		Pagereference buyProductPage = productTableController.buyCurrentItemPage();
		Pagereference detailPage = productTableController.showMoreDetailPage();
		Test.stopTest();

		System.assertEquals(productTablePage.getUrl(), tablePage.getUrl());
		System.assertEquals(buyProductTablePage.getUrl(), buyProductPage.getUrl());
		System.assertEquals(currentProductPage.getUrl(), detailPage.getUrl());
	}

}
