defmodule UniboExPoc.Barcode do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Barcode.BarcodeNomenclature
    resource UniboExPoc.Barcode.BarcodeNomenclatureTranslation
    resource UniboExPoc.Barcode.BarcodeNomenclature.Version
    resource UniboExPoc.Barcode.BarcodeRule
    resource UniboExPoc.Barcode.BarcodeRuleTranslation
    resource UniboExPoc.Barcode.BarcodeRule.Version
    resource UniboExPoc.Barcode.BarcodeMapping
    resource UniboExPoc.Barcode.BarcodeMapping.Version
    resource UniboExPoc.Barcode.GS1ApplicationIdentifier
    resource UniboExPoc.Barcode.GS1ApplicationIdentifierTranslation
    resource UniboExPoc.Barcode.GS1ApplicationIdentifier.Version
  end
end
