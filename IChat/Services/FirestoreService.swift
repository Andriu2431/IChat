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
    
    var currentUser: MUser!

    // метод буде перевіряти чи по індентифікатору юзера є вся його інформація, якщо так то вернемо його, ні то помилку
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void) {
        // добираємось до документа по назві user.uid
        let decumentReference = self.userReference.document(user.uid)
        decumentReference.getDocument { document, error in
            if let document = document, document.exists {
                // записуємо в модель
                guard let muser = MUser(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToMUser))
                    return
                }
                // сетапим користувача
                self.currentUser = muser
                completion(.success(muser))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }

    // метод буде зберігати дані про користувача в Firestore
    func saveProfileWith(id: String, email: String, username: String?, avatarImage: UIImage?, description: String?, sex: String?,
                         completion: @escaping (Result<MUser, Error>) -> Void) {

        // перевіримо чи всі данні заповнені
        guard Validators.isFilled(username: username, description: description, sex: sex) else {
            completion(.failure(UserError.notFilled))
            return
        }

        // перевіримо чи фото яке прийшло в метод не є стандартним
        guard avatarImage != UIImage(named: "avatar") else {
            completion(.failure(UserError.photoNotExist))
            return
        }

        // передаємо ці дані в модель
        var muser = MUser(username: username!,
                          email: email,
                          avatarStringURL: "not exist",
                          description: description!,
                          sex: sex!,
                          id: id)

        // загружаємо отримане фото в Storage
        StorageService.shared.upload(photo: avatarImage!) { result in
            switch result {
            case .success(let url):
                // передаємо силку на фото в модель
                muser.avatarStringURL = url.absoluteString
                // всі дані загрузимо лише тоді, коли фото загрузиться в storage
                // в Firestore в колекції users створюємо новий документ з назвою muser.id туди передаємо інформацію по юзеру - вертаємо дані які передали або помилку
                self.userReference.document(muser.id).setData(muser.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(muser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        } // StorageService
    } // saveProfileWith
    
    // метод буде створювати очікуваний чат в firestore
    func createWaitingChat(message: String, receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        // силка на колекцію waitingChat
        let referense = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        // силка на колекцію messages
        let messageRef = referense.document(self.currentUser.id).collection("messages")
        
        // повідомлення
        let message = MMessage(user: currentUser, content: message)
        // це є чат
        let chat = MChat(friendUsername: currentUser.username,
                         friendAvatarStringURL: currentUser.avatarStringURL,
                         lastMessageContent: message.content,
                         friendId: currentUser.id)
        
        // додаємо в waitingChat за назвою currentUser.id чат
        referense.document(currentUser.id).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // якщо все успішно тоді добавляємо документ по силці messageRef
            messageRef.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(Void()))
            }
        }
    }
}
