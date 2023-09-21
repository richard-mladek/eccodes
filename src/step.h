#pragma once

#include <tuple>
#include <map>
#include <exception>
#include <stdexcept>
#include <string>
#include <vector>
#include <tuple>
#include <algorithm>
#include <unordered_map>
#include <cassert>
#include <sstream>
#include <optional>

#include "step_unit.h"

class Step {
public:
    // Constructors
    Step() : internal_value_(0), internal_unit_(Unit::Value::SECOND) {}

    Step(double value, const Unit& unit) : internal_unit_{unit}, unit_{internal_unit_} {init_double(value, unit);}
    Step(double value, Unit::Value unit) {init_double(value, Unit{unit});}
    Step(double value, long unit) {init_double(value, Unit{unit});}
    Step(double value, const std::string& unit) {init_double(value, Unit{unit});}

    Step(long value, const Unit& unit) { init_long(value, unit);}
    Step(long value, Unit::Value unit) {init_long(value, Unit{unit});}
    Step(long value, long unit) {init_long(value, Unit{unit});}
    Step(long value, const std::string& unit) {init_long(value, Unit{unit});}

    // Getters
    template <typename T> T value() const;
    template <typename T> T value(const Unit& unit) const;
    template <typename T> T value(const std::string& format) const;
    Unit unit() const { return unit_; }

    // Setters
    Step& set_unit(const std::string& unit_name) {unit_ = Unit{unit_name}; return *this;}
    Step& set_unit(long unit_code) {unit_ = Unit{unit_code}; return *this;}
    Step& set_unit(const Unit& new_unit) {unit_ = new_unit; return *this;}
    Step& set_unit(const Unit::Value new_unit) {unit_ = new_unit; return *this;}

    // Operators
    bool operator==(const Step& other) const;
    bool operator!=(const Step& other) const;
    Step operator+(const Step& step) const;
    Step operator-(const Step& step) const;
    bool operator>(const Step& step) const;
    bool operator<(const Step& step) const;
    Step copy() const {
        Step ret{};
        ret.internal_value_ = internal_value_;
        ret.internal_unit_ = internal_unit_;
        ret.unit_ = unit_;
        return ret;
    }

    // Methods
    Step& optimize_unit();
    friend std::pair<Step, Step> find_common_units(const Step& startStep, const Step& endStep);


private:
    void init_long(long value, const Unit& unit);
    void init_double(double value, const Unit& unit);
    void sanity_check() const;
    Step& recalculateValue() {
        if (internal_value_ == 0) {
            internal_unit_ = unit_;
            return *this;
        }

        Seconds<long> seconds = to_seconds<long>(internal_value_, internal_unit_);
        long multiplier = Unit::get_converter().unit_to_duration(unit_.value<Unit::Value>());
        internal_value_ = seconds.count() / multiplier;
        internal_unit_ = unit_;

        return *this;
    }

    long internal_value_;
    Unit internal_unit_;
    Unit unit_;
};


Step step_from_string(std::string step);
std::vector<Step> parse_range(const std::string& range_str);
std::pair<Step, Step> find_common_units(const Step& startStep, const Step& endStep);


template <typename T> T Step::value() const {
    if (internal_value_ == 0) {
        return 0;
    }
    if (internal_unit_ == unit_) {
        return internal_value_;
    }
    Seconds<T> seconds = to_seconds<T>(internal_value_, internal_unit_);
    T value = from_seconds<T>(seconds, unit_);
    return value;
}

template <typename T> T Step::value(const Unit& unit) const {
    if (internal_value_ == 0) {
        return 0;
    }
    if (internal_unit_ == unit) {
        return internal_value_;
    }
    Seconds<T> seconds = to_seconds<T>(internal_value_, internal_unit_);
    T value = from_seconds<T>(seconds, unit);
    return value;
}
