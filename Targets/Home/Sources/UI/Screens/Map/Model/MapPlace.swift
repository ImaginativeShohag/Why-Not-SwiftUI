//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CoreLocation
import MapKit

struct MapPlace: Identifiable, Hashable, Equatable {
    var id: String {
        name
    }

    let name: String
    let location: CLLocationCoordinate2D
    let description: String

    // Manual implementation of `Hashable` and `Equatable` for `CLLocationCoordinate2D`
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(location.latitude)
        hasher.combine(location.longitude)
        hasher.combine(description)
    }

    static func == (lhs: MapPlace, rhs: MapPlace) -> Bool {
        lhs.name == rhs.name &&
            lhs.location.latitude == rhs.location.latitude &&
            lhs.location.longitude == rhs.location.longitude &&
            lhs.description == rhs.description
    }

    func toMapItem() -> MKMapItem {
        var mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location))
        mapItem.name = name
        return mapItem
    }
}

extension MapPlace {
    static let places: [MapPlace] = [
        MapPlace(
            name: "Barisal Division",
            location: CLLocationCoordinate2D(latitude: 22.6954585, longitude: 90.3187848),
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ac tamen hic mallet non dolere. Quis est, qui non oderit libidinosam, protervam adolescentiam? Duo Reges: constructio interrete. Illud dico, ea, quae dicat, praeclare inter se cohaerere. Quos quidem tibi studiose et diligenter tractandos magnopere censeo. Nulla profecto est, quin suam vim retineat a primo ad extremum. An potest, inquit ille, quicquam esse suavius quam nihil dolere? "
        ),
        MapPlace(
            name: "Chattogram Division",
            location: CLLocationCoordinate2D(latitude: 22.3260781, longitude: 91.7498278),
            description: "Aut unde est hoc contritum vetustate proverbium: quicum in tenebris? Non est enim vitium in oratione solum, sed etiam in moribus. Sed quoniam et advesperascit et mihi ad villam revertendum est, nunc quidem hactenus; Quid est enim aliud esse versutum? Qua ex cognitione facilior facta est investigatio rerum occultissimarum. Scio enim esse quosdam, qui quavis lingua philosophari possint; Ut optime, secundum naturam affectum esse possit. Nemo igitur esse beatus potest. Et homini, qui ceteris animantibus plurimum praestat, praecipue a natura nihil datum esse dicemus? "
        ),
        MapPlace(
            name: "Dhaka Division",
            location: CLLocationCoordinate2D(latitude: 23.7807777, longitude: 90.3492858),
            description: "Igitur ne dolorem + qui+dem. N&am il=lud vehementer repugnat, eundem beatum esse et multis malis oppressum. Piso, familiaris noster, et alia multa et hoc loco Stoicos irridebat: Quid enim? Nos quidem Virtutes sic natae sumus, ut tibi serviremus, aliud negotii nihil habemus. An hoc usque quaque, aliter in vita? Sed finge non solum callidum eum, qui aliquid improbe faciat, verum etiam praepotentem, ut M. Itaque nostrum est-quod nostrum dico, artis est-ad ea principia, quae accepimus. Qui igitur convenit ab alia voluptate dicere naturam proficisci, in alia summum bonum ponere?"
        ),
        MapPlace(
            name: "Khulna Division",
            location: CLLocationCoordinate2D(latitude: 22.8454448, longitude: 89.4624617),
            description: "Ad eas enim res ab Epicuro praecepta dantur. Quod quidem iam fit etiam in Academia. Deinde prima illa, quae in congressu solemus: Quid tu, inquit, huc? Quae contraria sunt his, malane? Sed residamus, inquit, si placet. Ergo hoc quidem apparet, nos ad agendum esse natos. Iubet igitur nos Pythius Apollo noscere nosmet ipsos. Verba tu fingas et ea dicas, quae non sentias?"
        ),
        MapPlace(
            name: "Mymensingh Division",
            location: CLLocationCoordinate2D(latitude: 24.7489639, longitude: 90.3789864),
            description: "Quo invento omnis ab eo quasi capite de summo bono et malo disputatio ducitur. Quae cum dixisset paulumque institisset, Quid est? Quis hoc dicit? Tollitur beneficium, tollitur gratia, quae sunt vincla concordiae. Levatio igitur vitiorum magna fit in iis, qui habent ad virtutem progressionis aliquantum. Quo tandem modo? Sed ego in hoc resisto; Atqui, inquam, Cato, si istud optinueris, traducas me ad te totum licebit."
        ),
        MapPlace(
            name: "Rajshahi Division",
            location: CLLocationCoordinate2D(latitude: 24.3802282, longitude: 88.5709965),
            description: "Gerendus est mos, modo recte sentiat. Id quaeris, inquam, in quo, utrum respondero, verses te huc atque illuc necesse est. Aliter enim explicari, quod quaeritur, non potest. Primum cur ista res digna odio est, nisi quod est turpis? Non igitur potestis voluptate omnia dirigentes aut tueri aut retinere virtutem. Rationis enim perfectio est virtus; Idem etiam dolorem saepe perpetiuntur, ne, si id non faciant, incidant in maiorem."
        ),
        MapPlace(
            name: "Rangpur Division",
            location: CLLocationCoordinate2D(latitude: 25.7499116, longitude: 89.2270261),
            description: "An me, inquam, nisi te audire vellem, censes haec dicturum fuisse? Tum ille timide vel potius verecunde: Facio, inquit. Nisi enim id faceret, cur Plato Aegyptum peragravit, ut a sacerdotibus barbaris numeros et caelestia acciperet? Tu autem negas fortem esse quemquam posse, qui dolorem malum putet. Itaque eos id agere, ut a se dolores, morbos, debilitates repellant."
        ),
        MapPlace(
            name: "Sylhet Division",
            location: CLLocationCoordinate2D(latitude: 24.8998373, longitude: 91.8259625),
            description: "Quid iudicant sensus? Quasi ego id curem, quid ille aiat aut neget. Oculorum, inquit Plato, est in nobis sensus acerrimus, quibus sapientiam non cernimus. Sed ego in hoc resisto;"
        )
    ]

    static let coxsBazarMapPlace = MapPlace(
        name: "Cox's Bazar",
        location: CLLocationCoordinate2D(
            latitude: 21.5164985,
            longitude: 91.8819745
        ),
        description: "Cox’s Bazar is a town on the southeast coast of Bangladesh. It’s known for its very long, sandy beachfront, stretching from Sea Beach in the north to Kolatoli Beach in the south."
    )
}
