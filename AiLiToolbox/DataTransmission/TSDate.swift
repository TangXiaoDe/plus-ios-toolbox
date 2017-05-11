//
//  TSDataBaseManager.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/14.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  数据库管理类


/// 时间类型
///
/// - simple: 个人主页
/// 1天内显示 今\n天，
/// 1天到2天显示 昨\n天，
/// 2天以上显示月日如 24\n12月、09\n2 月，当月份小于 10 时，数字和月份之间有个空格
///
/// - normal: 动态列表时间戳格式转换
/// 一分钟内显示一分钟
/// 一小时内显示几分钟前
/// 一天内显示几小时前
/// 1天到2天显示昨天
/// 2天到9天显示几天前
/// 9天以上显示月日如（05-21）
///
/// - detail: 动态详情
/// 一分钟内显示一分钟
/// 一小时内显示几分钟前，
/// 一天内显示几小时前，
/// 1天到2天显示如（昨天 20:36），
/// 2天到9天显示如（五天前 20：34），
/// 9天以上显示如（02-28 19:15）
public enum DateType {
    case simple
    case normal
    case detail
}

public class TSDate: NSObject {
    
    // MARK: - Lifecycle
    /// 日程表
    private let calendar = Calendar(identifier: .gregorian)
    /// 当前时间
    private var now: Date
    /// 当天零点
    private var today: Date
    /// 昨天零点
    private var yesterday: Date
    /// 9 天前
    private var nightday: Date
    /// 一分钟前
    private var oneMinute: Date
    /// 一小时前
    private var oneHour: Date
    /// 格式转换器
    private let formatter = DateFormatter()
    
    /// 后台返回时间
    private var date = Date()
    
    // MARK: - Lifecycle
    public override init() {
        now = Date()
        today = calendar.startOfDay(for: now)
        yesterday = calendar.date(byAdding: Calendar.Component.day, value: -1, to: today, wrappingComponents: false)!
        nightday = calendar.date(byAdding: Calendar.Component.day, value: -9, to: today, wrappingComponents: false)!
        oneMinute = calendar.date(byAdding: Calendar.Component.minute, value: -1, to: now, wrappingComponents: false)!
        oneHour = calendar.date(byAdding: Calendar.Component.hour, value: -1, to: now, wrappingComponents: false)!
    }
    
    /// 用于测试的初始化
    convenience init(_ nowDate: Date) {
        self.init()
        now = nowDate
    }
    
    // MARK: - Public
    
    /// 转换成时间
    ///
    /// - Parameters:
    ///   - type: 转换类型
    ///   - timeStamp: 时间戳
    /// - Returns: 计算后的字符串
    public func dateString(_ type: DateType, nsDate: NSDate) -> String {
        date = convertToDate(nsDate)
        var dateString = ""
        switch type {
        case .simple:
            dateString = simpleDate()
        case .normal:
            dateString = normalDate()
        case .detail:
            dateString = detailDate()
        }
        return dateString
    }
    
    /// 转换成时间
    ///
    /// - Parameters:
    ///   - type: 转换类型
    ///   - timeStamp: 时间戳
    /// - Returns: 计算后的字符串
    //    func dateString(_ type: DateType, time: NSDate) -> String {
    //        let timeStampInt = Int(time.timeIntervalSince1970)
    //        return dateString(type, timeStamp: timeStampInt)
    //    }
    
    // MARK: - Private
    
    /// simple 类型的时间
    /// - Note:
    /// 个人主页
    /// 1天内显示 今\n天，
    /// 1天到2天显示 昨\n天，
    /// 2天以上显示月日如 24\n12月、09\n2 月，当月份小于 10 时，数字和月份之间有个空格
    ///
    private func simpleDate() -> String {
        if isLate(than: today) {
            return "今\n天"
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            return "昨\n天"
        }
        formatter.dateFormat = "MM"
        let month = Int(formatter.string(from: date))!
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        if month < 10 {
            return day + "\n\(month) 月"
        }
        return day + "\n\(month)月"
    }
    
    /// normal 类型的时间
    ///
    /// - Note:
    /// 动态列表时间戳格式转换
    /// 一分钟内显示一分钟内
    /// 一小时内显示几分钟前
    /// 一天内显示几小时前
    /// 1天到2天显示昨天
    /// 2天到9天显示几天前
    /// 9天以上显示月日如（05-21）
    private func normalDate() -> String {
        let comphoent = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        if isLate(than: oneMinute) {
            return "1分钟内"
        }
        if isLate(than: oneHour) && isEarly(than: oneMinute) {
            return "\((comphoent.minute)!)分钟前"
        }
        if isLate(than: today) && isEarly(than: oneHour) {
            return "\((comphoent.hour)!)小时前"
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            return "昨天"
        }
        if isLate(than: nightday) && isEarly(than: yesterday) {
            return "\((comphoent.day)!)天前"
        }
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }
    
    /// detail 类型的时间
    ///
    /// - Note:
    /// 一分钟内显示一分钟内
    /// 一小时内显示几分钟前，
    /// 一天内显示几小时前，
    /// 1天到2天显示如（昨天 20:36），
    /// 2天到9天显示如（五天前 20：34），
    /// 9天以上显示如（02-28 19:15）
    private func detailDate() -> String {
        let comphoent = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        if isLate(than: oneMinute) {
            return "1分钟内"
        }
        if isLate(than: oneHour) && isEarly(than: oneMinute) {
            return "\((comphoent.minute)!)分钟前"
        }
        if isLate(than: today) && isEarly(than: oneHour) {
            return "\((comphoent.hour)!)小时前"
        }
        if isLate(than: yesterday) && isEarly(than: today) {
            formatter.dateFormat = "HH:mm"
            return "昨天 \(formatter.string(from: date))"
        }
        if isLate(than: nightday) && isEarly(than: yesterday) {
            formatter.dateFormat = "HH:mm"
            return "\((comphoent.day)!)天前 \(formatter.string(from: date))"
        }
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    /// 是否早于某个时间
    private func isEarly(than compareDate: Date) -> Bool {
        return date < compareDate
    }
    
    /// 是否晚于某个时间
    private func isLate(than compareDate: Date) -> Bool {
        return date >= compareDate
    }
    
    /// 将 NSDate 转换成 Date
    private func convertToDate(_ nsDate: NSDate) -> Date {
        return Date(timeIntervalSince1970: nsDate.timeIntervalSince1970)
    }
}

extension String {
    /// 将时间格式转换为 date
    public func convertToDate() -> NSDate {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)
        return NSDate(timeIntervalSince1970: date!.timeIntervalSince1970)
    }
}

extension Int {
    /// 将时间戳转换成 date
    public func convertToDate() -> NSDate {
        return NSDate(timeIntervalSince1970: TimeInterval(self))
    }
}
