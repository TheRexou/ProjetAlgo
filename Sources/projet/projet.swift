import Foundation

struct Etudiant {
    var id: UInt
    var nom: String
    var prenom: String
    var adresseMail: String
    var telephone: String?
    var telephoneVisible: Bool?
    var promotion: String
    var roles: [String]
    var disponibilites: [String]
    var pointsFaibles: [String]
    var pointsForts: [String]
    var disponible: Bool
}

struct Offre {
    var id: UInt
    var etudiant: Etudiant
    var domaine: String
    var typeAide: String
    var active: Bool
    var date: Date

}

struct Demande {
    var id: UInt
    var etudiant: Etudiant
    var domaine: String
    var description: String
    var niveau: String
    var active: Bool
    var date: Date

}

let lsDomaines: [String] = [
    "Mathématiques", "Physique", "Chimie", "Biologie", "Informatique", "Langues", "Histoire",
    "Géographie", "Littérature", "Philosophie", "Économie", "Droit",
]

let lsTypeAide: [String] = [
    "Leçon complète", "Explication d'un point", "Résolution d'exercices"
]

let days: [String] = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]


func matchToRegex(input:String, regex:String) -> Bool {
    if (input.range(of: regex, options: .regularExpression) != nil) {
        return true
    } else {
        print("La saisie est invalide, réessayez.")
        return false
    }
}

func createEtudiant(lsEtudiant: inout [Etudiant]) {
    var resultLine: String

    print("Nom de l'étudiant :")
    var name: String = ""
    resultLine = readLine()!
    while (!matchToRegex(input: resultLine, regex: "^[A-Za-z]+$")) {
        print("Prénom et nom de l'étudiant :")
        resultLine = readLine()!
    }
    name = resultLine

    print("Prénom et nom de l'étudiant :")
    var firstName: String = ""
    resultLine = readLine()!
    while (!matchToRegex(input: resultLine, regex: "^[A-Za-z]+$")) {
        print("Prénom et nom de l'étudiant :")
        firstName = readLine()!
    }
    firstName = resultLine

    print("Addresse e-mail de l'étudiant :")
    var email: String = ""
    resultLine = readLine()!
    while (!matchToRegex(input: resultLine, regex: #"^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$"#)) {
        print("Addresse e-mail de l'étudiant :")
        resultLine = readLine()!
    }
    email = resultLine
    
    print("Numéro de téléphone de l'étudiant :")
    var phoneNumber: String = ""
    resultLine = readLine()!
    while (!matchToRegex(input: resultLine, regex: #"^\+?[0-9]+$"#)) { // on ne vérifie pas si le numéro est d'un certain format car il peut y avoir des numéros internationaux 
        print("Numéro de téléphone de l'étudiant :")
        resultLine = readLine()!
    }
    phoneNumber = resultLine
    
    print("Le numéro de téléphone doit être visible ? (Oui / NON) :")
    resultLine = readLine()!
    var phoneNumberVisible: Bool = false
    if resultLine.lowercased() == "oui" {
        phoneNumberVisible = true
    }
    
    print("Promotion & année de l'étudiant :")
    var promotion: String = ""
    resultLine = readLine()!
    while (!matchToRegex(input: resultLine, regex: "^[A-Za-z0-9 ]+$")) {
        print("Promotion & année de l'étudiant :")
        resultLine = readLine()!
    }
    promotion = resultLine

    var roles: [String] = []
    while (roles.isEmpty) {
        print("Rôle(s) de l'étudiant (au moins un) :")
        print("L'étudiant est-il un parrain ? (Oui / NON) :")
        resultLine = readLine()!
        if resultLine.lowercased() == "oui" {
            roles.append("Parrain")
        }
        print("L'étudiant est-il un filleul ? (Oui / NON) :")
        resultLine = readLine()!
        if resultLine.lowercased() == "oui" {
            roles.append("Filleul")
        }
        if roles.isEmpty {
            print("Au moins un rôle doit être sélectionné.")
        }
    }

    print("L'étudiant est disponible (séparés par des virgules) :")
    var disponibilites: [String] = []
    // Stock dans un tableau les disponibilités de l'étudiant [Lundi, Mardi, Mercredi, Jeudi, Vendredi, Samedi, Dimanche]
    for day: String in days {
        print("- \(day)")
    }
    
    // Jours de disponibilité
    var daysAvailable: [String] = []
    // Regarde si la saisie est correcte
    while daysAvailable.isEmpty {
        resultLine = readLine()!
        let daysAvailableTemp: [String] = resultLine.components(separatedBy: ",")
        for dayAvailable: String in daysAvailableTemp {
            if days.contains(dayAvailable.trimmingCharacters(in: .whitespacesAndNewlines)) {
                // Si le jour est dans la liste des jours, on l'ajoute
                daysAvailable.append(dayAvailable.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        if daysAvailable.isEmpty {
            print("Au moins un jour de disponibilité doit être sélectionné (séparés par des virgules) :")
            for day: String in days {
                print("- \(day)")
            }
        }
    }
    // Demande les horaires pour chaque jour
    for day: String in days {
        var matchDay: Bool = false
        for dayAvailable: String in daysAvailable {
            if day == dayAvailable{
                // Si le point faible est dans la liste des domaines, on l'ajoute
                matchDay = true
                print("Horraire de disponibilité pour \(day) (ex : 08h00 - 11h30 / 14h00 - 17h45) :")
                let pattern: String = #"^(?:([01][0-9]|2[0-3])h[0-5][0-9] - ([01][0-9]|2[0-3])h[0-5][0-9])( /\s*(?:([01][0-9]|2[0-3])h[0-5][0-9] - ([01][0-9]|2[0-3])h[0-5][0-9]))*$"#
                resultLine = readLine()!
                while (!matchToRegex(input: resultLine, regex: pattern)) {
                    print("Horraire de disponibilité pour \(day) (ex : 08h00 - 11h30 / 14h00 - 17h45) :")
                    resultLine = readLine()!
                }
                
                disponibilites.append(resultLine)
            }
        }
        if !matchDay {
            disponibilites.append("Non disponible")
        }
    }
    
    // Si l'étudiant est filleul, demande les points faibles
    var pointsFaibles: [String] = []
    if roles.contains("Filleul") {
        print("Point(s) faible(s) de l'étudiant (séparés par des virgules) :")
        for domaine: String in lsDomaines {
            print("- \(domaine)")
        }
        // Regarde si la saisie est correcte
        resultLine = readLine()!
        let pointsFaiblesTemp: [String] = resultLine.components(separatedBy: ",")
        for pointFaible: String in pointsFaiblesTemp {
            if lsDomaines.contains(pointFaible.trimmingCharacters(in: .whitespacesAndNewlines)) {
                // Si le point faible est dans la liste des domaines, on l'ajoute
                pointsFaibles.append(pointFaible)
            }
        }
    }
    
    // Si l'étudiant est parrain, demande les points forts
    var pointsForts: [String] = []
    if roles.contains("Parrain") {
        print("Point(s) fort(s) de l'étudiant (séparés par des virgules) :")
        for domaine: String in lsDomaines {
            print("- \(domaine)")
        }
        // Regarde si la saisie est correcte
        resultLine = readLine()!
        let pointsFortsTemp: [String] = resultLine.components(separatedBy: ",")
        for pointFort: String in pointsFortsTemp {
            if lsDomaines.contains(pointFort.trimmingCharacters(in: .whitespacesAndNewlines)) {
                // Si le point fort est dans la liste des domaines, on l'ajoute
                pointsForts.append(pointFort)
            }
        }
    }

    print("L'étudiant est actuellement disponible ? (OUI / Non) :")
    resultLine = readLine()!
    var disponible: Bool = true
    if resultLine == "Non" {
        disponible = false
    }

    var newEtudiant: Etudiant = Etudiant(
        id: UInt(lsEtudiant.count), nom: name, prenom: firstName, adresseMail: email, telephone: phoneNumber,
        telephoneVisible: phoneNumberVisible, promotion: promotion, roles: roles,
        disponibilites: disponibilites, pointsFaibles: pointsFaibles, pointsForts: pointsForts,
        disponible: disponible
    )

    if (!isDuplicateEtudiant(lsEtudiant: &lsEtudiant, newEtudiant: &newEtudiant)) {
        lsEtudiant.append(newEtudiant)
        print("Étudiant créé avec succès !")
    } else {
        print("Erreur : Un étudiant avec le même email ou numéro de téléphone existe déjà.")
    }
}

func modifyEtudiant(lsEtudiant: inout [Etudiant], etudiantId: Int) {
    var etudiant: Etudiant = lsEtudiant[etudiantId]
    var resultLine: String

    print("Que souhaite-vous modifier de l'étudiant '\(etudiant.nom)' ?")
    print("Modifiable: nom, prénom, adresse email, téléphone, visibilité du téléphone, promotion, rôles, disponibilités, points faibles, points forts, disponible")
    resultLine = readLine()!
    switch resultLine {
        case "nom":
            print("Nouveau nom :")
            resultLine = readLine()!
            etudiant.nom = resultLine
        case "prénom":
            print("Nouveau prénom :")
            resultLine = readLine()!
            etudiant.prenom = resultLine
        case "adresse email":   
            print("Nouvelle adresse email :")
            resultLine = readLine()!
            etudiant.adresseMail = resultLine
        case "téléphone":
            print("Nouveau numéro de téléphone :")
            resultLine = readLine()!
            etudiant.telephone = resultLine
        case "visibilité du téléphone":
            print("Le numéro de téléphone doit être visible ? (Oui / NON) :")
            resultLine = readLine()!
            if resultLine.lowercased() == "oui" {
                etudiant.telephoneVisible = true
            } else {
                etudiant.telephoneVisible = false
            }
        case "promotion":
            print("Nouvelle promotion & année :")
            resultLine = readLine()!
            etudiant.promotion = resultLine
        case "rôles":
            var roles: [String] = []
            while (roles.isEmpty) {
                print("Rôle(s) de l'étudiant (au moins un) :")
                print("L'étudiant est-il un parrain ? (Oui / NON) :")
                resultLine = readLine()!
                if resultLine.lowercased() == "oui" {
                    roles.append("Parrain")
                }
                print("L'étudiant est-il un filleul ? (Oui / NON) :")
                resultLine = readLine()!
                if resultLine.lowercased() == "oui" {
                    roles.append("Filleul")
                }
                if roles.isEmpty {
                    print("Au moins un rôle doit être sélectionné.")
                }
            }
            etudiant.roles = roles
        case "disponibilités":
            var disponibilites: [String] = etudiant.disponibilites
            var counter: Int = 0
            for day: String in days {
                print("- \(day) : \(disponibilites[counter])")
                counter += 1
            }
            print("Choisissez le jour à modifier :")
            resultLine = readLine()!
            if days.contains(resultLine) {
                print("Horraire de disponibilité pour \(resultLine) (ex : 08h00 - 11h30 / 14h00 - 17h45) :")
                let pattern: String = #"^(?:([01][0-9]|2[0-3])h[0-5][0-9] - ([01][0-9]|2[0-3])h[0-5][0-9])( /\s*(?:([01][0-9]|2[0-3])h[0-5][0-9] - ([01][0-9]|2[0-3])h[0-5][0-9]))*$"#
                resultLine = readLine()!
                while (!matchToRegex(input: resultLine, regex: pattern)) {
                    print("Horraire de disponibilité pour \(resultLine) (ex : 08h00 - 11h30 / 14h00 - 17h45) :")
                    resultLine = readLine()!
                }

                let dayIndex = days.firstIndex(of: resultLine)!
                disponibilites[dayIndex] = resultLine
                etudiant.disponibilites = disponibilites
            } else {
                print("Jour non reconnu.")
            }
        case "points faibles":
            if etudiant.roles.contains("Filleul") {
                var pointsFaibles: [String] = []
                print("Point(s) faible(s) de l'étudiant (séparés par des virgules) :")
                for domaine: String in lsDomaines {
                    print("- \(domaine)")
                }
                // Regarde si la saisie est correcte
                resultLine = readLine()!
                let pointsFaiblesTemp: [String] = resultLine.components(separatedBy: ",")
                for pointFaible: String in pointsFaiblesTemp {
                    if lsDomaines.contains(pointFaible.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        // Si le point faible est dans la liste des domaines, on l'ajoute
                        pointsFaibles.append(pointFaible)
                    }
                }
                etudiant.pointsFaibles = pointsFaibles
            } else {
                print("L'étudiant n'est pas filleul.")
            }
        case "points forts":
            if etudiant.roles.contains("Parrain") {
                var pointsForts: [String] = []
                print("Point(s) fort(s) de l'étudiant (séparés par des virgules) :")
                for domaine: String in lsDomaines {
                    print("- \(domaine)")
                }
                // Regarde si la saisie est correcte
                resultLine = readLine()!
                let pointsFortsTemp: [String] = resultLine.components(separatedBy: ",")
                for pointFort: String in pointsFortsTemp {
                    if lsDomaines.contains(pointFort.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        // Si le point fort est dans la liste des domaines, on l'ajoute
                        pointsForts.append(pointFort)
                    }
                }
            } else {
                print("L'étudiant n'est pas parrain.")
            }
        case "disponible":
            print("L'étudiant est actuellement disponible ? (OUI / Non) :")
            resultLine = readLine()!
            if resultLine == "Non" {
                etudiant.disponible = false
            } else {
                etudiant.disponible = true
            }
        default:
            print("Rien n'était sélectionné ou mauvaise réponse")
    }


}

func searchEtudiant(lsEtudiant: inout [Etudiant], etudiantId: Int) -> Int {

    var index: Int = 0
    var low = 0
    var high = lsEtudiant.count - 1
    while low <= high {
        let mid: Int = (high - low) / 2
        if lsEtudiant[mid].id == etudiantId {
            index = mid
            return index
        } else if lsEtudiant[mid].id > etudiantId {
            high = mid - 1
        } else {
            low = mid + 1
        }
    }
    return index
}


func isDuplicateEtudiant(lsEtudiant: inout [Etudiant], newEtudiant: inout Etudiant) -> Bool {
    for etud in lsEtudiant {
        if etud.adresseMail == newEtudiant.adresseMail || etud.telephone == newEtudiant.telephone {
            return true
        }
    }
    return false
}

func isDuplicateDemande(lsDemande: inout [Demande], newDemande: inout Demande) -> Bool {

    for demande in lsDemande {
        if demande.description == newDemande.description && demande.domaine == newDemande.domaine && demande.niveau == newDemande.niveau && demande.etudiant.id == newDemande.etudiant.id {
            return true
        }
    }

    return false
}

func isDuplicateOffre(lsOffre: inout [Offre], newOffre: inout Offre) -> Bool {
    
    for offre in lsOffre {
        if offre.domaine == newOffre.domaine && offre.etudiant.id == newOffre.etudiant.id && offre.typeAide == newOffre.typeAide {
            return true
        }
    }
    return false
}

func createDemande(lsDemande: inout [Demande], lsEtudiant: inout [Etudiant]) {

    var resultLine: String

    print("Veuillez saisir votre nom:")

    resultLine = readLine()!

    for etudiant in lsEtudiant {
        if resultLine == etudiant.nom {
            print(
                "Id: \(etudiant.id)\t\tNom: \(etudiant.nom)\t\tAdresse mail: \(etudiant.adresseMail)"
            )
        }
    }

    print("Veuillez saisir votre id:")

    resultLine = readLine()!

    let etudiant = lsEtudiant[searchEtudiant(lsEtudiant: &lsEtudiant, etudiantId: Int(resultLine)!)]

    print("Choisissez le domaine demandé:")

    var i = 1

    for domaine in etudiant.pointsFaibles {
        print("\(i). \(domaine)")
        i += 1
    }

    resultLine = readLine()!

    let choixDomaine = etudiant.pointsFaibles[Int(resultLine)! - 1]

    print("Donner la description de votre demande:")

    let description = readLine()!

    print("Quel est le niveau attendu?")

    let niveau = readLine()!

    let date = Date()    

    var newDemande = Demande(
            id: UInt(lsDemande.count),
            etudiant: etudiant, domaine: choixDomaine, description: description, niveau: niveau,
            active: true, date: date)

    if (!isDuplicateDemande(lsDemande: &lsDemande, newDemande: &newDemande)) {
        print("Demande créée avec succès!")
        lsDemande.append(newDemande)
    } else {
        print("La demande existe déjà.")
    }
}

func deleteDemande(lsDemande: inout [Demande], lsEtudiant: inout [Etudiant]) -> Void {

    var resultLine: String

    print("Veuillez saisir votre nom:")

    resultLine = readLine()!

    for etudiant in lsEtudiant {
        if resultLine == etudiant.nom {
            print(
                "Id: \(etudiant.id)\t\tNom: \(etudiant.nom)\t\tAdresse mail: \(etudiant.adresseMail)"
            )
        }
    }

    print("Veuillez saisir votre id:")

    let etudId = Int(readLine()!)!
    var tempLsDemandeId: [UInt] = []
    var ind = 1
    for demande in lsDemande {
        if etudId == demande.etudiant.id && demande.active {
            print("\(ind).")
            printDemande(demande: demande)
            tempLsDemandeId.append(demande.id)
            ind += 1
        }
    }
    
    print("Veuillez saisir l'identifiand ou les identifiants de la demande ou des demandes à supprimer:")
    print("Ex: 1,2,3")
    
    resultLine = readLine()!
    let lsDemandesToDeleteStr: [String] = resultLine.components(separatedBy: ",")
    var lsDemandesToDeleteInt: [UInt] = []
    for demandeIdStr in lsDemandesToDeleteStr {
        lsDemandesToDeleteInt.append(UInt(demandeIdStr.trimmingCharacters(in: .whitespacesAndNewlines))!)
    }

    for i in 0..<lsDemande.count {
        for offreToDeleteId in lsDemandesToDeleteInt {
            if lsDemande[i].id == offreToDeleteId {
                lsDemande[i].active = false
                break
            } // O(n^2)
        }
    }

    print("Demande(s) supprimée(s)!")

}

func printDemande(demande: Demande) -> Void {

    let calendar = Calendar.current
    let day = calendar.component(.day, from: demande.date)
    let month = calendar.component(.month, from: demande.date)
    let hour = calendar.component(.hour, from: demande.date)
    let minutes = calendar.component(.minute, from: demande.date)
    print("\tDemande id: \(demande.id)")
    print("\tEtudiant id: \(demande.etudiant.id)")
    print("\tDomaine: \(demande.domaine)")
    print("\tDescription: \(demande.description)")
    print("\tNiveau: \(demande.niveau)")
    print("\tDate: \(day)/\(month) \(hour):\(minutes)")

}

func modifyDemande(lsDemande: inout [Demande], lsEtudiant: inout [Etudiant]) {

    var resultLine: String

    print("Veuillez saisir votre nom:")

    resultLine = readLine()!

    for etudiant in lsEtudiant {
        if resultLine == etudiant.nom {
            print(
                "Id: \(etudiant.id)\t\tNom: \(etudiant.nom)\t\tAdresse mail: \(etudiant.adresseMail)"
            )
        }
    }


    
    print("Veuillez saisir votre id:")

    let etudId = Int(readLine()!)!
    var tempLsDemandeId: [UInt] = []
    var ind = 1
    for demande in lsDemande {
        if etudId == demande.etudiant.id && demande.active {
            print("\(ind).")
            printDemande(demande: demande)
            tempLsDemandeId.append(demande.id)
            ind += 1
        }
    }
    
    print("Veuillez saisir l'offre à modifier:")

    let demandeIdtoModify: UInt = UInt(readLine()!)!

    for i in 0..<lsDemande.count {
        if demandeIdtoModify == lsDemande[i].id {
            print("Que voulez-vous modifier? (Une seule chose peut être modifiée)")
            print("Modifiable: domaine, description, niveau, active")
            print("Ex: domaine")
            let modifyOpt: String = readLine()!
            switch modifyOpt {
                case "domaine":
                    print("Choisissez le domaine demandé:")

                    let etudiant: Etudiant = lsEtudiant[searchEtudiant(lsEtudiant: &lsEtudiant, etudiantId: Int(resultLine)!)]
                    var i = 1

                    for domaine in etudiant.pointsFaibles {
                        print("\(i). \(domaine)")
                        i += 1
                    }

                    resultLine = readLine()!

                    let choixDomaine = etudiant.pointsFaibles[Int(resultLine)! - 1]


                    let date = Date()    
                    lsDemande[i].date = date
                    lsDemande[i].domaine = choixDomaine
                    print("Domaine modifié")

                case "niveau":
                
                    print("Quel est le niveau attendu?")

                    let niveau = readLine()!
                    let date = Date()    
                    lsDemande[i].date = date
                    lsDemande[i].niveau = niveau
                    
                    print("Type d'aide modifié")
                
                case "description":
                    print("Donner la description de votre demande:")

                    let description = readLine()!
                    let date = Date()    
                    lsDemande[i].date = date
                    lsDemande[i].description = description
                
                case "active":
                    if lsDemande[i].active == true {
                        lsDemande[i].active = false
                        print("Demande désactivée")
                    } else {
                        lsDemande[i].active = true
                        let date = Date()
                        lsDemande[i].date = date
                        print("Demande activée")
                    }

                default:
                    print("Rien n'était sélectionné ou mauvaise réponse")
            }
        }

    

    }
}

func createOffre(lsOffre: inout [Offre], lsEtudiant: inout [Etudiant]) -> Void {


    var resultLine: String

    print("Veuillez saisir votre nom:")

    resultLine = readLine()!

    for etudiant in lsEtudiant {
        if resultLine == etudiant.nom {
            print(
                "Id: \(etudiant.id)\t\tNom: \(etudiant.nom)\t\tAdresse mail: \(etudiant.adresseMail)"
            )
        }
    }

    print("Veuillez saisir votre id:")

    resultLine = readLine()!

    let etudiant = lsEtudiant[searchEtudiant(lsEtudiant: &lsEtudiant, etudiantId: Int(resultLine)!)]

    print("Choisissez le domaine offert:")

    var i = 1

    for domaine in etudiant.pointsForts {
        print("\(i). \(domaine)")
        i += 1
    }

    resultLine = readLine()!

    let choixDomaine = etudiant.pointsForts[Int(resultLine)! - 1]

    print("Précisez le type d'aide proposé:")
    i = 1
    for typeAide in lsTypeAide {
        print("\(i). \(typeAide)")
        i += 1
    }
    
    resultLine = readLine()!

    let typeAide = lsTypeAide[Int(resultLine)!-1]

    let date = Date()    

    var newOffre = Offre(
        id: UInt(lsOffre.count),
        etudiant: etudiant, domaine: choixDomaine, typeAide: typeAide, active: true, date: date)

    if (!isDuplicateOffre(lsOffre: &lsOffre, newOffre: &newOffre)) {
        print("Offre créée avec succès!")
        lsOffre.append(newOffre)
    } else {
        print("L'offre existe déjà.")
    }
}

func deleteOffre(lsOffre: inout [Offre], lsEtudiant: inout [Etudiant]) {

    var resultLine: String

    print("Veuillez saisir votre nom:")

    resultLine = readLine()!

    for etudiant in lsEtudiant {
        if resultLine == etudiant.nom {
            print(
                "Id: \(etudiant.id)\t\tNom: \(etudiant.nom)\t\tAdresse mail: \(etudiant.adresseMail)"
            )
        }
    }

    print("Veuillez saisir votre id:")

    let etudId = Int(readLine()!)!
    var tempLsOffreId: [UInt] = []
    var ind = 1
    for offre in lsOffre {
        if etudId == offre.etudiant.id && offre.active {
            print("\(ind).")
            printOffre(offre: offre)
            tempLsOffreId.append(offre.id)
            ind += 1
        }
    }
    
    print("Veuillez saisir l'identifiant ou les identifiants de l'offre ou des offres à supprimer:")
    print("Ex: 1,2,3")
    
    resultLine = readLine()!
    let lsOffresToDeleteStr: [String] = resultLine.components(separatedBy: ",")
    var lsOffresToDeleteInt: [UInt] = []
    for offreIdStr in lsOffresToDeleteStr {
        lsOffresToDeleteInt.append(UInt(offreIdStr.trimmingCharacters(in: .whitespacesAndNewlines))!)
    }

    for i in 0..<lsOffre.count {
        for offreToDeleteId in lsOffresToDeleteInt {
            if lsOffre[i].id == offreToDeleteId {
                lsOffre[i].active = false
                break
            } // O(n^2)
        }
    }

    print("Offre(s) supprimée(s)!")
}

func printOffre(offre: Offre) -> Void {
    let calendar = Calendar.current
    let day = calendar.component(.day, from: offre.date)
    let month = calendar.component(.month, from: offre.date)
    let hour = calendar.component(.hour, from: offre.date)
    let minutes = calendar.component(.minute, from: offre.date)
    print("\tOffre id: \(offre.id)")
    print("\tEtudiant id: \(offre.etudiant.id)")
    print("\tDomaine: \(offre.domaine)")
    print("\tType d'aide: \(offre.typeAide)")
    print("\tDate: \(day)/\(month) \(hour):\(minutes)")

}

func modifyOffre(lsOffre: inout [Offre], lsEtudiant: inout [Etudiant]) {

    var resultLine: String

    print("Veuillez saisir votre nom:")

    resultLine = readLine()!

    for etudiant in lsEtudiant {
        if resultLine == etudiant.nom {
            print(
                "Id: \(etudiant.id)\t\tNom: \(etudiant.nom)\t\tAdresse mail: \(etudiant.adresseMail)"
            )
        }
    }


    
    print("Veuillez saisir votre id:")

    let etudId = Int(readLine()!)!
    var tempLsOffreId: [UInt] = []
    var ind = 1
    for offre in lsOffre {
        if etudId == offre.etudiant.id && offre.active {
            print("\(ind).")
            printOffre(offre: offre)
            tempLsOffreId.append(offre.id)
            ind += 1
        }
    }
    
    print("Veuillez saisir l'offre à modifier:")

    let offreIdtoModify: UInt = UInt(readLine()!)!
    
    for i in 0..<lsOffre.count {
        if offreIdtoModify == lsOffre[i].id {
            print("Que voulez-vous modifier? (Une seule chose peut être modifiée)")
            print("Modifiable: domaine, typeAide, active")
            print("Ex: domaine")
            let modifyOpt: String = readLine()!
            switch modifyOpt {
                case "domain":
                    print("Choisissez le domaine offert:")

                    let etudiant: Etudiant = lsEtudiant[searchEtudiant(lsEtudiant: &lsEtudiant, etudiantId: Int(resultLine)!)]
                    var i = 1

                    for domaine in etudiant.pointsForts {
                        print("\(i). \(domaine)")
                        i += 1
                    }

                    resultLine = readLine()!

                    let choixDomaine = etudiant.pointsForts[Int(resultLine)! - 1]


                    let date = Date()    
                    lsOffre[i].date = date
                    lsOffre[i].domaine = choixDomaine
                    print("Domaine modifié")

                case "typeAide":
                    print("Précisez le type d'aide proposé:")
                    var i = 1
                    for typeAide in lsTypeAide {
                        print("\(i). \(typeAide)")
                        i += 1
                    }
    
                    resultLine = readLine()!

                    let typeAide = lsTypeAide[Int(resultLine)!-1]

                    let date = Date()    
                    lsOffre[i].date = date
                    lsOffre[i].typeAide = typeAide
                    print("Type d'aide modifié")
                
                case "active":
                    if lsOffre[i].active == true {
                        lsOffre[i].active = false
                        print("Offre désactivée")
                    } else {
                        lsOffre[i].active = true
                        let date = Date()
                        lsOffre[i].date = date
                        print("Offre activée")
                    }

                default:
                    print("Rien n'était sélectionné ou mauvaise réponse")
            }
        }

    

    }
}

func printStats(lsDemande: inout [Demande], lsOffre: inout [Offre]) {
    print("Veuillez choisir un domaine pour voir ses statistiques:")
    var i = 1
    for domaine in lsDomaines {
        print("\(i). \(domaine)")
        i += 1
    }
    print("Ex: Mathématiques")
    let domaine: String = readLine()!
    var oi = 0
    for offre in lsOffre {
        if domaine == offre.domaine {
            oi += 1
        }
    }
    print("Offres avec ce domaine: \(oi)")
    var di = 0
    for demande in lsDemande {
        if domaine == demande.domaine {
            di += 1
        }
    }
    print("Demandes avec ce domaine: \(di)")
    print("Total d'annonces avec ce domaine: \(di+oi)")
}

func printStatsTension(lsDemande: inout [Demande], lsOffre: inout [Offre]) {
    print("Domaines \"en tension\"")
    for domaine in lsDomaines {
        
    }
    
}

@main
struct projet {
    static func main() {
        var lsEtudiant: [Etudiant] = []
        var lsDemande: [Demande] = []
        var lsOffre: [Offre] = []

        var q: Bool = false

        repeat {
            print("Choisissez la commande:")

            print("ce\t\tcréer étudiant")
            print("co\t\tcréer offre")
            print("cd\t\tcréer demande")

            print("ae\t\tafficher étudiants")
            print("ao\t\tafficher offres")
            print("ad\t\tafficher demandes")
            
            print("q\t\tquitter")
            let resultLine = readLine()!
            switch resultLine {
                case "ce":
                    print("Création de l'étudiant...")
                    createEtudiant(lsEtudiant: &lsEtudiant)
                case "co":
                    print("Création de l'offre...")
                    createOffre(lsOffre: &lsOffre, lsEtudiant: &lsEtudiant)
                case "cd":
                    print("Création de la demande...")
                    createDemande(lsDemande: &lsDemande, lsEtudiant: &lsEtudiant)
                case "q":
                    print("Déconnexion...")
                    q = true
                default:
                    print("Commande non reconnue, réessayez")
            }
        } while !q
    }
}
// https://github.com/TheRexou/ProjetAlgo