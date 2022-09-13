//
//  FirestoreService.swift
//  IChat
//
//  Created by Andrii Malyk on 13.09.2022.
//

import Firebase
import FirebaseFirestore

// тут будемо працювати з Firestore
class FirestoreService {
    
    static let shared = FirestoreService()
    
    // ініціалізація Firestore
    let db = Firestore.firestore()
    
    // доступ до колекції
    private var userReference: CollectionReference {
        return db.collection("users")
    }
    
    // метод буде зберігати дані про користувача в Firestore
    func saveProfileWith(id: String, email: String, username: String?, avatarImageString: String?, description: String?, sex: String?,
                         completion: @escaping (Result<MUser, Error>) -> Void) {
        
        // перевіримо чи всі данні заповнені
        guard Validators.isFilled(username: username, description: description, sex: sex) else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        // передаємо ці дані в модель
        let muser = MUser(username: username!,
                          email: email,
                          avatarStringURL: "not exist",
                          description: description!,
                          sex: sex!,
                          id: id)
        
        // в Firestore в колекції users створюємо новий документ з назвою muser.id туди передаємо інформацію по юзеру - вертаємо дані які передали або помилку
        self.userReference.document(muser.id).setData(muser.representation) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(muser))
            }
        }
    }
}
