import Foundation

struct Etudiant {
    var id: UInt
    var nom: String
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
    var etudiant: Etudiant
    var domaine: String
    var typeAide: String
    var active: Bool
    var date: Date

}

struct Demande {
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


func matchToRegex(input:String, regex:String, variable: inout String) -> Bool {
    if (input.range(of: regex, options: .regularExpression) != nil) {
        return true
    } else {
        print("La saisie est invalide, réessayez.")
        return false
    }
}

func createEtudiant(lsEtudiant: inout [Etudiant]) {
    var resultLine: String
    let days: [String] = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]

    print("Prénom et nom de l'étudiant :")
    var name: String = ""
    while (!matchToRegex(input: readLine()!, regex: "^[A-Za-z ]+$", variable: &name)) {
        print("Prénom et nom de l'étudiant :")
    }
    print("Addresse e-mail de l'étudiant :")
    var email: String = ""
    while (!matchToRegex(input: readLine()!, regex: "^[a-z0-9.@]+$", variable: &email)) {
        print("Addresse e-mail de l'étudiant :")
    }
    print("Numéro de téléphone de l'étudiant :")
    var phoneNumber: String = ""
    while (!matchToRegex(input: readLine()!, regex: "^[0-9]+$", variable: &phoneNumber)) {
        print("Numéro de téléphone de l'étudiant :")
    }
    print("Le numéro de téléphone doit être visible ? (Oui / NON) :")
    resultLine = readLine()!
    var phoneNumberVisible: Bool = false
    if resultLine.lowercased() == "oui" {
        phoneNumberVisible = true
    }
    print("Promotion & année de l'étudiant :")
    var promotion: String = ""
    while (!matchToRegex(input: readLine()!, regex: "^[A-Za-z0-9 ]+$", variable: &promotion)) {
        print("Promotion & année de l'étudiant :")
    }
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
    print("Disponibilité(s) de l'étudiant :")
    // Stock dans un tableau les disponibilités de l'étudiant [Lundi, Mardi, Mercredi, Jeudi, Vendredi, Samedi, Dimanche]
    var disponibilites: [String] = []
    for day: String in days {
        print("L'étudiant est-il disponible le \(day) ? (Oui / NON) :")
        if (readLine()!.lowercased() == "oui") {
            print("Horraire de disponibilité (ex : 08h00 - 11h30 / 14h00 - 17h45) :")
            disponibilites.append(readLine()!)
        } else {
            disponibilites.append("Non disponible")
        }
    }

    print("Point(s) faible(s) de l'étudiant (séparés par des virgules) :\n")
    for domaine: String in lsDomaines {
        print("- \(domaine)")
    }
    // Regarde si la saisie est correcte
    resultLine = readLine()!
    var pointsFaibles: [String] = []
    let pointsFaiblesTemp: [String] = resultLine.components(separatedBy: ",")
    for pointFaible: String in pointsFaiblesTemp {
        if lsDomaines.contains(pointFaible.trimmingCharacters(in: .whitespacesAndNewlines)) {
            // Si le point faible est dans la liste des domaines, on l'ajoute
            pointsFaibles.append(pointFaible)
        }
    }

    print("Point(s) fort(s) de l'étudiant :")
    for domaine: String in lsDomaines {
        print("- \(domaine)")
    }
    // Regarde si la saisie est correcte
    resultLine = readLine()!
    var pointsForts: [String] = []
    let pointsFortsTemp: [String] = resultLine.components(separatedBy: ",")
    for pointFort: String in pointsFortsTemp {
        if lsDomaines.contains(pointFort.trimmingCharacters(in: .whitespacesAndNewlines)) {
            // Si le point fort est dans la liste des domaines, on l'ajoute
            pointsForts.append(pointFort)
        }
    }
    print("L'étudiant est actuellement disponible ? (Oui / Non) :")
    resultLine = readLine()!
    var disponible: Bool = true
    if resultLine == "Non" {
        disponible = false
    }

    var newEtudiant: Etudiant = Etudiant(
        id: UInt(lsEtudiant.count), nom: name, adresseMail: email, telephone: phoneNumber,
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
            etudiant: etudiant, domaine: choixDomaine, description: description, niveau: niveau,
            active: true, date: date)

    if (!isDuplicateDemande(lsDemande: &lsDemande, newDemande: &newDemande)) {
        print("Demande créée avec succès!")
        lsDemande.append(newDemande)
    } else {
        print("La demande existe déjà.")
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

    var newOffre = Offre(etudiant: etudiant, domaine: choixDomaine, typeAide: typeAide, active: true, date: date)

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
    var tempLsOffre: [Offre] = []
    var ind = 0
    for offre in lsOffre {
        if etudId == offre.etudiant.id {
            print("\(ind + 1).")
            printOffre(offre: offre)
            tempLsOffre.append(offre)
            ind += 1
        }
    }

    // TODO: finish function

}

func printOffre(offre: Offre) {
    let calendar = Calendar.current
    let day = calendar.component(.day, from: offre.date)
    let month = calendar.component(.month, from: offre.date)
    let hour = calendar.component(.hour, from: offre.date)
    let minutes = calendar.component(.minute, from: offre.date)
    print("\tEtudiant id: \(offre.etudiant.id)")
    print("\tDomaine: \(offre.domaine)")
    print("\tType d'aide: \(offre.typeAide)")
    print("\tDate: \(day)/\(month) \(hour):\(minutes)")

}

@main
struct projet {
    static func main() {
        var lsEtudiant: [Etudiant] = []
        var lsDemande: [Demande] = []
        var lsOffre: [Offre] = []

        while true {
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
                    return
                default:
                    print("Commande non reconnue, réessayez")
            }
        }

    }
}
