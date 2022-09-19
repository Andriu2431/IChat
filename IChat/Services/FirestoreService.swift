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
    
    // добираємось до очікуваних чатів юзера
    private var waitingChatsRef: CollectionReference {
        return  db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
    
    // добираємось до активних чатів юзера
    private var activeChatsRef: CollectionReference {
        return  db.collection(["users", currentUser.id, "activeChats"].joined(separator: "/"))
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

    // метод буде видаляти очікуваний чат з firestore
    func deleteWaitingChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        // беремо чат людини який будемо видаляти
        waitingChatsRef.document(chat.friendId).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteMessages(chat: chat, completion: completion)
        }
    }

    // метод видаляє вже messages з firestore
    private func deleteMessages(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        // силка на колекцію messages
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")

        getWaitingChatMessages(chat: chat) { result in
            switch result {
            case .success(let messages):
                // проходимось по всіх повідомленнях та видаляємо їх
                for message in messages {
                    // дістаємо id message
                    guard let documentId = message.id else { return }
                    // добираємось до повідомлення по documentId
                    let messageRef = reference.document(documentId)
                    // видаляємо це повідомлення
                    messageRef.delete { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // метод дістає messages з firestore
    private func getWaitingChatMessages(chat: MChat, completion: @escaping (Result<[MMessage], Error>) -> Void) {
        // силка на колекцію messages
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        // масив messages
        var messages = [MMessage]()
        // дістаємо документи з неї
        reference.getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // проходимось по кожному та зтворюємо типу MMessage
            for document in querySnapshot!.documents {
                // створюємо message
                guard let message = MMessage(document: document) else { return }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    // метод буде міняти з очікуваного чату на активний
    func changeToActive(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        // отримуємо messages з firestore
        getWaitingChatMessages(chat: chat) { result in
            switch result {
            case .success(let messages):
                // видаляємо очікуваний чат
                self.deleteWaitingChat(chat: chat) { result in
                    switch result {
                    case .success():
                        // створюємо активний чат
                        self.createActiveChat(chat: chat, messages: messages) { result in
                            switch result {
                            case .success():
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // метод буде створювати активний чат
    private func createActiveChat(chat: MChat, messages: [MMessage], completion: @escaping (Result<Void, Error>) -> Void) {
        let messageRef = activeChatsRef.document(chat.friendId).collection("messages")
        // створюємо новий документ під назвою chat.friendId та передаємо туди дані chat.representation
        activeChatsRef.document(chat.friendId).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // в колекцію messages додаємо повідомлення як нові документи
            for message in messages {
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
    
    // відправка повідомлення в firestore
    func sendMessage(chat: MChat, message: MMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        // активний чат в мого друга зімною
        let friendRef = userReference.document(chat.friendId).collection("activeChats").document(currentUser.id)
        // силка на повідомлення друга
        let friendMessageRef = friendRef.collection("messages")
        // силка на мої повідомлення
        let myMessageRef = userReference.document(currentUser.id).collection("activeChats").document(chat.friendId).collection("messages")
        
        let chatForFriend = MChat(friendUsername: currentUser.username,
                                  friendAvatarStringURL: currentUser.avatarStringURL,
                                  lastMessageContent: message.content,
                                  friendId: currentUser.id)
        friendRef.setData(chatForFriend.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            // добавляємо другу нове повідомлення
            friendMessageRef.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                // добавляємо нове повідомлення собі
                myMessageRef.addDocument(data: message.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
}
