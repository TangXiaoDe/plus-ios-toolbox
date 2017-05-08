//
//  Int+Extension.swift
//  AiLiToolbox
//
//  Created by lip on 2017/5/3.
//
//  Int相关扩展

import UIKit

extension Int {
    /// 判断一个整数是否为 0 (为空)
    var isEqualZero: Bool {
        return self == 0
    }
}

extension Array {
    /// 将数组转为 字符串
    /// 例如 [1, 2, 3] -> "1,2,3"
    func convertToString() -> String? {
        if self.isEmpty {
            return nil
        }
        var tempArray: Array<String> = [String]()
        for number in self {
            tempArray.append("\(number)")
        }
        return tempArray.joined(separator: ",")
    }
}
