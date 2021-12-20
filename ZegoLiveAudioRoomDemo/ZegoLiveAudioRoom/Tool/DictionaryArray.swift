//
//  DictionaryArray.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/17.
//

import Foundation

// a container contains arrary and dictionary
class DictionaryArrary<KEY, VALUE> where KEY : Hashable, VALUE : NSObject {
    private var list: [VALUE] = []
    private var dict: [KEY : VALUE] = [ : ]
    private let queue = DispatchQueue(label: "im.zego.dictionary.arrary.queue", attributes: .concurrent)
    
    var count: Int {
        get {
            queue.sync {
                return list.count
            }
        }
    }
    
    func allObjects() -> [VALUE] {
        return list
    }
    
    func addObj(_ key: KEY, _ value: VALUE) {
        queue.sync(flags: .barrier) {
            if let old = dict[key] {
                list = list.filter() { $0 != old }
            }
            dict[key] = value
            list.append(value)
        }
    }

    func removeObj(_ key: KEY) {
        queue.sync(flags: .barrier) {
            let obj = dict[key]
            guard let obj = obj else {
                return
            }
            dict.removeValue(forKey: key)
            list = list.filter() { $0 != obj }
        }
    }
    
    func getObj(_ key: KEY) -> VALUE? {
        queue.sync {
            guard let obj = dict[key] else {
                return nil
            }
            return obj
        }
    }
}
