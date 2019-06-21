public with sharing class ProductTablePageControllerExtension {

	public Id currentProductTableId {
		get {
			return currentProductTableId;
		}
		set {
			currentProductTableId = ApexPages.currentPage().getParameters().get('currentProductTableId');
		}
	}

	public ProductTablePageControllerExtension(ApexPages.StandardSetController productController) {
	}

	public ProductTablePageControllerExtension(ApexPages.StandardController stdController) {
	}

	public PageReference buyCurrentItemPage() {
		PageReference buyProductTablePage = new PageReference(System.Label.PageReference_BuyCurrentProductTable);
		buyProductTablePage.getParameters().put('Id', currentProductTableId);
		return buyProductTablePage;
	}

	public PageReference showMoreDetailPage() {
		PageReference currentProductPage = new PageReference(System.Label.PageReference_CurrentProductTable);
		currentProductPage.setRedirect(true);
		currentProductPage.getParameters().put('Id', currentProductTableId);
		return currentProductPage;
	}

	public PageReference backToProductTablePage() {
		PageReference productTablePage = new PageReference(System.Label.PageReference_ProductTable);
		return productTablePage;
	}

}