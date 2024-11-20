void moveToFront<I>(List<I> list, I item) {
  list.remove(item);
  list.insert(0, item);
}

void moveToEnd<I>(List<I> list, I item) {
  list.remove(item);
  list.add(item);
}

class DynamicRangeLoading<I> {
  List<Section> sections = [];
  int? size;
  Map<int, I> data = {};

  DynamicRangeLoading(Section section): sections = [section], size = section.end;

  Section get activeSection => sections.first;

  // The incomplete sections will always be in front
  bool get complete => activeSection.complete;

  void skipTo(int i) {
    for (var section in sections) {
      if (section.contains(i)) {
        if (i > section.index) {
          // Section has not progressed until the requested index
          // Split the section and move the new section to the front
          final newSection = section.split(i);
          sections.insert(0, newSection);
        } else {
          // Section is further ahead than requested skipTo
          // move section to front since that work has higher prio
          if (!section.complete && section != activeSection) {
            moveToFront(sections, section);
          }
        }
        return;
      }
    }

    throw Exception("Out of range");
  }

  int getNextIndex() {
    if (complete) {
      throw Exception("Cannot get next index. All work is done");
    }
    return activeSection.index;
  }

  void pumpIndex() {
    if (activeSection.pump()) {
      //activeSection has ended
      if (sections.length > 1) {
        moveToEnd(sections,activeSection);
      }
    }
  }

  Future<I> process(Future<I> Function(int) func) async{
    final index = getNextIndex();
    final val = await func(index);
    data[index] = val;
    pumpIndex();
    return val;
  }

  void setData(I value) {
    data[activeSection.index] = value;
    activeSection.index += 1;
  }
}

class Section {
  int begin;
  int? end;
  int index;

  Section(this.begin, this.end): index = begin;

  bool contains(int i) => begin <= i && (end == null ? true : i < end!);

  Section split(int i) {
    final newSection = Section(i, end);
    end = i;
    return newSection;
  }

  bool get complete => index == end;

  //returns false if there is still work to do in the section
  bool pump() {
    if (end == null || index < end!) {
      index += 1;
    }
    return complete;
  }
}
