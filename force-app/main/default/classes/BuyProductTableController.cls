public class BuyProductTableController {
	public Contact customerContact { get; set; }
	public String errorMessage { get; set; }
	public String inputWarningMessage { get; set; }
	public String confirmMessage { get; set; }
	public Product_Table__c desiredProductTable { get; set; }
	private Id receivedProductTableId;
	private Decimal totalAmount = 0;
	private Integer unitsAvailable = 0;
	public Integer unitCount {
		get {
			return unitCount;
		} set {
			if (value <= 0) {
				unitCount = 0;
			} else {
				unitCount = value;
			}
		}
	}

	public Decimal getUnitsAvailable() {
		if (unitCount > 0) {
			unitsAvailable = (Integer)desiredProductTable.Units_Available__c - unitCount;
		} else {
			unitsAvailable = (Integer)desiredProductTable.Units_Available__c;
		}
		return unitsAvailable;
	}

	public Decimal getTotalAmount() {
		if (unitCount > 0) {
			totalAmount = unitCount * (Decimal)desiredProductTable.Unit_Price__c;
		} else {
			totalAmount = 0;
		}
		return totalAmount;
	}

	public BuyProductTableController(ApexPages.StandardController stdController) {
		receivedProductTableId = (Id)stdController.getId();
		desiredProductTable = [
			SELECT Id, Name, Unit_Price__c, Units_Available__c
			FROM Product_Table__c
			WHERE Id = :receivedProductTableId
			LIMIT 1
		];
		customerContact = new Contact();
	}

	public void buyCurrentItem() {
		Savepoint beforeContactUpsering = Database.setSavepoint();
		List<Contact> customerContactWithProducts = new List<Contact>();
		List<Order_Table__c> orderTableForProducts = new List<Order_Table__c>();
		if (String.isNotBlank(customerContact.Email__c)) {
			List<Contact> searchedContactsByEmailList = [
				SELECT Id, Email__c, FirstName, LastName
				FROM Contact
				WHERE Email__c = :customerContact.Email__c
			];
			if (searchedContactsByEmailList.size() != 0) {
				searchedContactsByEmailList[0].FirstName = customerContact.FirstName;
				searchedContactsByEmailList[0].LastName = customerContact.LastName;
				customerContact.Id = searchedContactsByEmailList[0].Id;
				customerContactWithProducts.add(searchedContactsByEmailList[0]);
			} else {
				customerContactWithProducts.add(customerContact);
			}
			try {
				upsert customerContactWithProducts;
				Savepoint beforeOrderTableCreating = Database.setSavepoint();
				if ((unitCount > 0) && (unitsAvailable >= 0) && (totalAmount > 0)) {
					Order_Table__c customerOrder = new Order_Table__c(
						Product__c = receivedProductTableId,
						Units__c = unitCount,
						Order_Amount__c = totalAmount,
						Contact__c = customerContact.Id
					);
					orderTableForProducts.add(customerOrder);
					insert orderTableForProducts;
				} else {
					Database.rollback(beforeOrderTableCreating);
					clearPageMessages();
					inputWarningMessage = System.Label.Units_Available + ' '
						+ (Integer)desiredProductTable.Units_Available__c;
				}
				if (orderTableForProducts.size() != 0) {
					desiredProductTable.Units_Available__c = unitsAvailable;
					update desiredProductTable;
					clearPageMessages();
					confirmMessage = System.Label.Order_Table_Confirm;
				}
			} catch (DmlException e) {
				Database.rollback(beforeContactUpsering);
				clearPageMessages();
				errorMessage = e.getMessage();
			}
		}
	}

	public PageReference backToProductTablePage() {
		PageReference currentProductPage = new PageReference(System.Label.PageReference_ProductTable);
		return currentProductPage;
	}

	private void clearPageMessages() {
		errorMessage = '';
		inputWarningMessage = '';
		confirmMessage = '';
	}

}