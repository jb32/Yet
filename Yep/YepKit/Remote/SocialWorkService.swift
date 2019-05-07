//
//  SocialWorkService.swift
//  Yep
//
//  Created by nixzhu on 15/11/17.
//  Copyright © 2015年 Catch Inc. All rights reserved.
//

import Foundation
import YepNetworking
import RealmSwift

private let githubBaseURL = URL(string: "https://api.github.com")!
private let dribbbleBaseURL = URL(string: "https://api.dribbble.com")!
private let instagramBaseURL = URL(string: "https://api.instagram.com")!

private func githubResource<A>(token: String, path: String, method: YepNetworking.Method, requestParameters: JSONDictionary, parse: @escaping (JSONDictionary) -> A?) -> Resource<A> {

    let jsonParse: (Data) -> A? = { data in
        if let json = decodeJSON(data) {
            return parse(json)
        }
        return nil
    }

    let jsonBody = encodeJSON(requestParameters)
    var headers = [
        "Content-Type": "application/json",
    ]

    headers["Authorization"] = "token \(token)"

    return Resource(path: path, method: method, requestBody: jsonBody, headers: headers, parse: jsonParse)
}

private func dribbbleResource<A>(token: String, path: String, method: YepNetworking.Method, requestParameters: JSONDictionary, parse: @escaping (JSONDictionary) -> A?) -> Resource<A> {

    let jsonParse: (Data) -> A? = { data in
        if let json = decodeJSON(data) {
            return parse(json)
        }
        return nil
    }

    let jsonBody = encodeJSON(requestParameters)
    var headers = [
        "Content-Type": "application/json",
    ]

    headers["Authorization"] = "Bearer \(token)"

    return Resource(path: path, method: method, requestBody: jsonBody, headers: headers, parse: jsonParse)
}

private func instagramResource<A>(token: String, path: String, method: YepNetworking.Method, requestParameters: JSONDictionary, parse: @escaping (JSONDictionary) -> A?) -> Resource<A> {

    let jsonParse: (Data) -> A? = { data in
        if let json = decodeJSON(data) {
            return parse(json)
        }
        return nil
    }

    let jsonBody = encodeJSON(requestParameters)
    let headers = [
        "Content-Type": "application/json",
    ]

    return Resource(path: path, method: method, requestBody: jsonBody, headers: headers, parse: jsonParse)
}

public enum SocialWorkPiece {
    case github(GithubRepo)
    case dribbble(DribbbleShot)
    case instagram(InstagramMedia)

    public var messageSocialWorkType: MessageSocialWorkType {
        switch self {
        case .github:
            return MessageSocialWorkType.githubRepo
        case .dribbble:
            return MessageSocialWorkType.dribbbleShot
        case .instagram:
            return MessageSocialWorkType.instagramMedia
        }
    }

    public var messageID: String {
        switch self {
        case .github(let repo):
            return "github_repo_\(repo.ID)"
        case .dribbble(let shot):
            return "dribbble_shot_\(shot.ID)"
        case .instagram(let media):
            return "instagram_media_\(media.ID)"
        }
    }
}

// MARK: Github Repo

public struct GithubRepo {
    public let ID: Int
    public let name: String
    public let fullName: String
    public let URLString: String
    public let description: String

    public let createdAt: Date
}

// MARK: Dribbble Shot

public struct DribbbleShot {
    public let ID: Int
    public let title: String
    public let description: String?
    public let htmlURLString: String

    public struct Images {
        public let hidpi: String?
        public let normal: String
        public let teaser: String
    }
    public let images: Images

    public let likesCount: Int
    public let commentsCount: Int

    public let createdAt: Date
}

// MARK: Instagram Media

public struct InstagramMedia {
    public let ID: String
    public let linkURLString: String

    public struct Images {
        public let lowResolution: String
        public let standardResolution: String
        public let thumbnail: String
    }
    public let images: Images

    public let likesCount: Int
    public let commentsCount: Int

    public let username: String

    public let createdAt: Date
}

// MARK: Sync

public func syncSocialWorksToMessagesForYepTeam() {

    tokensOfSocialAccounts(failureHandler: nil, completion: { tokensOfSocialAccounts in
        //println("tokensOfSocialAccounts: \(tokensOfSocialAccounts)")

        SafeDispatch.async {

            guard let realm = try? Realm() else {
                return
            }

            func messageIDsFromSyncSocialWorkPiece(_ socialWorkPiece: SocialWorkPiece, yepTeam: User, inRealm realm: Realm) -> [String] {

                let messageID = socialWorkPiece.messageID

                var message = messageWithMessageID(messageID, inRealm: realm)

                guard message == nil else {
                    return []
                }

                if message == nil {
                    let newMessage = Message()
                    newMessage.messageID = messageID
                    newMessage.mediaType = MessageMediaType.socialWork.rawValue

                    let socialWork = MessageSocialWork()
                    socialWork.type = socialWorkPiece.messageSocialWorkType.rawValue

                    switch socialWorkPiece {

                    case .github(let repo):

                        let repoID = repo.ID
                        var socialWorkGithubRepo = SocialWorkGithubRepo.getWithRepoID(repoID, inRealm: realm)

                        if socialWorkGithubRepo == nil {
                            let newSocialWorkGithubRepo = SocialWorkGithubRepo()
                            newSocialWorkGithubRepo.fillWithGithubRepo(repo)

                            realm.add(newSocialWorkGithubRepo)

                            socialWorkGithubRepo = newSocialWorkGithubRepo
                        }

                        socialWork.githubRepo = socialWorkGithubRepo

                    case .dribbble(let shot):

                        let shotID = shot.ID
                        var socialWorkDribbbleShot = SocialWorkDribbbleShot.getWithShotID(shotID, inRealm: realm)

                        if socialWorkDribbbleShot == nil {
                            let newSocialWorkDribbbleShot = SocialWorkDribbbleShot()
                            newSocialWorkDribbbleShot.fillWithDribbbleShot(shot)

                            realm.add(newSocialWorkDribbbleShot)

                            socialWorkDribbbleShot = newSocialWorkDribbbleShot
                        }

                        socialWork.dribbbleShot = socialWorkDribbbleShot

                    case .instagram:
                        break
                    }

                    newMessage.socialWork = socialWork

                    realm.add(newMessage)

                    message = newMessage
                }

                if let message = message {

                    message.fromFriend = yepTeam

                    var conversation = yepTeam.conversation

                    if conversation == nil {
                        let newConversation = Conversation()

                        newConversation.type = ConversationType.oneToOne.rawValue
                        newConversation.withFriend = yepTeam

                        realm.add(newConversation)

                        conversation = newConversation
                    }

                    if let conversation = conversation {

                        message.conversation = conversation

                        var sectionDateMessageID: String?
                        tryCreateSectionDateMessageInConversation(conversation, beforeMessage: message, inRealm: realm) { sectionDateMessage in
                            realm.add(sectionDateMessage)
                            sectionDateMessageID = sectionDateMessage.messageID
                        }

                        var messageIDs = [String]()
                        if let sectionDateMessageID = sectionDateMessageID {
                            messageIDs.append(sectionDateMessageID)
                        }
                        messageIDs.append(message.messageID)

                        return messageIDs

                    } else {
                        message.deleteInRealm(realm)
                    }
                }

                return []
            }

            let yepTeamUsername = "yep_team"

            func yepTeamFromDiscoveredUser(_ discoveredUser: DiscoveredUser, inRealm realm: Realm) -> User? {

                var yepTeam = userWithUsername(yepTeamUsername, inRealm: realm)

                if yepTeam == nil {
                    let newYepTeam = User()
                    newYepTeam.userID = discoveredUser.id
                    newYepTeam.username = discoveredUser.username ?? ""
                    newYepTeam.nickname = discoveredUser.nickname
                    newYepTeam.introduction = discoveredUser.introduction ?? ""
                    newYepTeam.avatarURLString = discoveredUser.avatarURLString
                    newYepTeam.badge = discoveredUser.badge ?? ""

                    newYepTeam.friendState = UserFriendState.yep.rawValue

                    realm.add(newYepTeam)

                    yepTeam = newYepTeam
                }

                return yepTeam
            }
        }
    })
}

