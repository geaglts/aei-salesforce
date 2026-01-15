public virtual with sharing class ETC_ControllerGetProduct {
    public List<Product2> productList;
    
    public ETC_ControllerGetProduct() {
        this.productList = new List<Product2>();
    }

    public void sync(ETC_ModelGetProducts serviceResponse) {
        buildSObject(serviceResponse.data);
    }

    public void buildSObject(List<ETC_ModelGetProducts.Data> products) {
        for (ETC_ModelGetProducts.Data product : products) {
            buildSObjectProduct(product);
        }
    }

    public void buildSObjectProduct(ETC_ModelGetProducts.Data product) {
        Product2 newProduct = new Product2();
        newProduct.Name = product.Articulo;
        newProduct.ProductCode = product.Articulo;
        newProduct.Description = product.Descripcion1;
        newProduct.External_Id__c = product.Articulo;
        newProduct.Rama__c = product.Rama;
        newProduct.Grupo__c = product.Grupo;
        newProduct.Categor_a__c = product.Categoria;
        newProduct.Familia__c = product.Familia;
        newProduct.L_nea__c = product.Linea;
        newProduct.Fabricante__c = product.Fabricante;
        newProduct.Clave_Fabricante__c = product.ClaveFabricante;
        newProduct.Impuesto__c = String.valueOf(product.Impuesto1);
        newProduct.Unidad__c = product.Unidad;
        newProduct.Tipo_Costeo__c = product.TipoCosteo;
        newProduct.Peso__c = product.Peso;
        newProduct.Tipo__c = product.Tipo;
        newProduct.Moneda_Costo__c = product.MonedaCosto;
        newProduct.Moneda_Precio__c = product.MonedaPrecio;
        newProduct.Margen_M_nimo__c = product.MargenMinimo;
        newProduct.Estatus__c = product.Estatus;
        newProduct.Tipo_Compra__c = product.TipoCompra;
        newProduct.Tiene_Movimientos__c = product.TieneMovimientos;
        newProduct.Ruta_Distribuci_n__c = product.RutaDistribucion;

        productList.add(newProduct);
    }
}