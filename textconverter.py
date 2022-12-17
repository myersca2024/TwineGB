import sys
import enum

# Classes for containing information
class Story:
    def __init__(self, title, pages):
        self.title = title
        self.pages = pages
        self.endCards = []

    def __str__(self):
        masterString = ""
        masterString += self.title + "\n\n"
        for page in self.pages:
            masterString += "Page " + str(page.id) + ":\n"
            for section in page.sections:
                masterString += section + "\n"
            for transition in page.transitions:
                masterString += transition.text + " => " + str(transition.dest) + "\n"
            masterString += "\n"
        return masterString

    def formatTitleText(self):
        words = self.title.split()
        formattedText = ""
        charCount = 0
        numLines = 1
        for word in words:
            wordLength = len(word)
            # If word can be appended to the line, append and add a space
            if (charCount + wordLength < 20):
                formattedText += (word + " ")
                charCount += wordLength + 1
            # If word can be perfectly appended to the line, append without space
            elif (charCount + wordLength == 20):
                formattedText += word
                charCount += wordLength
            # If word would exceed line maximum character count (20),
            elif (charCount + wordLength > 20):
                # and there are more lines available, start a new line
                if (numLines + 1 <= 3):
                    if charCount == 20:
                        formattedText += (word + " ")
                    else:
                        formattedText += ("\n" + word + " ")
                    charCount = wordLength + 1
                    numLines += 1
        self.title = formattedText

    def getNumPages(self):
        return len(self.pages)

    def getMaxSections(self):
        maxSections = -1
        for page in self.pages:
            if len(page.sections) > maxSections:
                maxSections = len(page.sections)
        return maxSections

    def getMaxCharCount(self):
        maxCharCount = -1
        for page in self.pages:
            for section in page.sections:
                if len(section) > maxCharCount:
                    maxCharCount = len(section)
        return maxCharCount

    def getMaxTransitionCount(self):
        maxTransitionCount = -1
        for page in self.pages:
            if len(page.transitions) > maxTransitionCount:
                maxTransitionCount = len(page.transitions)
        return maxTransitionCount

    def getMaxTransitionCharCount(self):
        maxTransitionCharCount = -1
        for page in self.pages:
            for transition in page.transitions:
                if len(transition.text) > maxTransitionCharCount:
                    maxTransitionCharCount = len(transition.text)
        return maxTransitionCharCount

class Page:
    def __init__(self, id, fullText, transitions):
        self.id = id
        self.fullText = fullText
        self.sections = []
        self.transitions = transitions

    def addSection(self, section):
        self.sections.append(section)

    def fullTextToSections(self):
        words = self.fullText.split()
        charCount = 0
        numLines = 1
        section = ""
        for word in words:
            wordLength = len(word)
            # If word can be appended to the line, append and add a space
            if (charCount + wordLength < 20):
                section += (word + " ")
                charCount += wordLength + 1
            # If word can be perfectly appended to the line, append without space
            elif (charCount + wordLength == 20):
                section += word
                charCount += wordLength
            # If word would exceed line maximum character count (20),
            elif (charCount + wordLength > 20):
                # and there are more lines available, start a new line
                if (numLines + 1 <= 17):
                    if charCount == 20:
                        section += (word + " ")
                    else:
                        section += ("\n" + word + " ")
                # and all lines are full, start a new section
                else:
                    self.addSection(section)
                    numLines = 0
                    section = word + " "
                charCount = wordLength + 1
                numLines += 1
        # Add the final, incomplete section to the list of sections
        self.addSection(section)

class Transition:
    def __init__(self, text, dest):
        self.text = text
        self.dest = dest

    def formatTransitionText(self):
        words = self.text.split()
        formattedText = ""
        charCount = 1
        numLines = 1
        for word in words:
            wordLength = len(word)
            # If word can be appended to the line, append and add a space
            if (charCount + wordLength < 20):
                formattedText += (word + " ")
                charCount += wordLength + 1
            # If word can be perfectly appended to the line, append without space
            elif (charCount + wordLength == 20):
                formattedText += word
                charCount += wordLength
            # If word would exceed line maximum character count (20),
            elif (charCount + wordLength > 20):
                # and there are more lines available, start a new line
                if (numLines + 1 <= 4):
                    if charCount == 20:
                        formattedText += (word + " ")
                    else:
                        formattedText += ("\n" + word + " ")
                    charCount = wordLength + 1
                    numLines += 1
        self.text = formattedText

class ParserState(enum.Enum):
    NONE = 0
    TITLE = 1
    ID = 2
    TRANSITION_TEXT = 3
    TRANSITION_DEST = 4
    TEXT = 5

# https://stackoverflow.com/questions/26520111/how-can-i-convert-special-characters-in-a-string-back-into-escape-sequences
def raw(string: str, replace: bool = False) -> str:
    r = repr(string)[1:-1]  # Strip the quotes from representation
    if replace:
        r = r.replace('\\\\', '\\')
    return r

class TextParser:
    def __init__(self):
        self.state = ParserState.NONE
        # Dummy initialization, used as storage reference
        self.story = Story("", [])
        self.activePage = Page(-1, "", [])
        self.activeTransition = Transition("", -1)
    
    def parseTextFile(self, fileContents):
        for line in fileContents:
            parts = line.split()
            for part in parts:
                match self.state:
                    case ParserState.NONE:
                        self.lookForCommand(part)
                    case ParserState.TITLE:
                        if not self.isStopCommand(part):
                            self.story.title += (part + " ")
                        else:
                            self.story.formatTitleText()
                    case ParserState.ID:
                        if not self.isStopCommand(part):
                            self.activePage.id = int(part)
                    case ParserState.TEXT:
                        if not self.isStopCommand(part):
                            self.activePage.fullText += (part + " ")
                    case ParserState.TRANSITION_TEXT:
                        if not self.isTransitionDestCommand(part):
                            self.activeTransition.text += (part + " ")
                    case ParserState.TRANSITION_DEST:
                        if not self.isStopCommand(part):
                            self.activeTransition.dest = int(part)
                        else:
                            self.activeTransition.formatTransitionText()
                            self.activePage.transitions.append(self.activeTransition)

    def isStopCommand(self, code):
        if code == "\;":
            self.state = ParserState.NONE
            return True
        else:
            return False

    def isTransitionDestCommand(self, code):
        if code == "//!":
            self.state = ParserState.TRANSITION_DEST
            return True
        else:
            return False
    
    def lookForCommand(self, code):
        # Symbols:
        # @ : Title
        # # : Page ID
        # ! : Page Transition
        # & : Page Text
        # { : Open Page
        # } : Close Page
        match code:
            case '@':
                self.state = ParserState.TITLE
            case '{':
                # Reinitialize page storage for new page
                self.activePage = Page(-1, "", [])
            case '#':
                self.state = ParserState.ID
            case '&':
                self.state = ParserState.TEXT
            case '!':
                # Reinitialize transition storage for new transition
                self.activeTransition = Transition("", -1)
                self.state = ParserState.TRANSITION_TEXT
            case '}':
                self.activePage.fullTextToSections()
                self.story.pages.append(self.activePage)
            case '~':
                self.story.endCards.append(self.activePage.id)

    def writeStoryToC(self, filename):
        file = open(filename, 'w')
        numPages = self.story.getNumPages()
        maxSections = self.story.getMaxSections()
        maxCharCount = max(0, min(round(self.story.getMaxCharCount() * 1.2), 340))
        maxTransitionCount = self.story.getMaxTransitionCount()
        maxTransitionCharCount = round(self.story.getMaxTransitionCharCount() * 1.2)

        fileContents = "#include \"story.h\"\n\n"
        fileContents += "const char title[" + str(round(len(self.story.title) * 1.2)) + "] = \"" + raw(self.story.title, True) + "\";\n"
        fileContents += "const char page_text[" + str(numPages) + "][" + str(maxSections) + "][" + str(maxCharCount) + "] = {\n"
        for i in range(0, numPages):
            fileContents += "\t{\n"
            for j in range(0, maxSections):
                if j < len(self.story.pages[i].sections):
                    fileContents += "\t\t\"" + raw(self.story.pages[i].sections[j], True) + "\",\n"
                else:
                    fileContents += "\t\t\"\",\n"
            fileContents += "\t},\n"
        fileContents += "};\n"

        if maxTransitionCount > 0:
            fileContents += "const char transition_text[" + str(numPages) + "][" + str(maxTransitionCount) + "][" + str(maxTransitionCharCount) + "] = {\n"
            for i in range(0, numPages):
                fileContents += "\t{\n"
                for j in range(0, maxTransitionCount):
                    if j < len(self.story.pages[i].transitions):
                        fileContents += "\t\t\"" + raw(self.story.pages[i].transitions[j].text, True) + "\",\n"
                    else:
                        fileContents += "\t\t\"\",\n"
                fileContents += "\t},\n"
            fileContents += "};\n"

        fileContents += "const uint8_t num_pages = " + str(numPages) + ";\n"
        fileContents += "const uint8_t num_sections[" + str(numPages) + "] = { "
        for i in range(0, numPages):
            fileContents += str(len(self.story.pages[i].sections)) + ", "
        fileContents += "};\n"

        fileContents += "const uint8_t num_transitions[" + str(numPages) + "] = { "
        for i in range(0, numPages):
            fileContents += str(len(self.story.pages[i].transitions)) + ", "
        fileContents += "};\n"

        if maxTransitionCount > 0:
            fileContents += "const int8_t transition_dests[" + str(numPages) + "][" + str(maxTransitionCount) + "] = {\n"
            for i in range(0, numPages):
                fileContents += "\t{\n"
                for j in range(0, maxTransitionCount):
                    if j < len(self.story.pages[i].transitions):
                        fileContents += "\t\t" + str(self.story.pages[i].transitions[j].dest) + ",\n"
                    else:
                        fileContents += "\t\t-1,\n"
                fileContents += "\t},\n"
            fileContents += "};\n"

        fileContents += "const uint8_t end_cards[" + str(len(self.story.endCards)) + "] = { "
        for endCard in self.story.endCards:
            fileContents += str(endCard) + ", "
        fileContents += "};\n"
        fileContents += "const uint8_t num_end_cards = " + str(len(self.story.endCards)) + ";\n\n"
        
        if maxTransitionCount > 0:
            fileContents += "const char* get_title_text() {\n\treturn title;\n}\n\nconst char* get_page_section(uint8_t page, uint8_t section) {\n\treturn page_text[page][section];\n}\n\nconst char* get_page_transition(uint8_t page, uint8_t num) {\n\treturn transition_text[page][num];\n}\n\nconst uint8_t get_num_pages() {\n\treturn num_pages;\n}\n\nconst uint8_t get_num_sections(uint8_t page) {\n\treturn num_sections[page];\n}\n\nconst uint8_t get_num_transitions(uint8_t page) {\n\treturn num_transitions[page];\n}\n\nconst int8_t get_transition_destination(uint8_t page, uint8_t transition) {\n\treturn transition_dests[page][transition];\n}\n\nbool is_end_card(uint8_t card) {\n\tfor (int i = 0; i < num_end_cards; ++i) {\n\t\tif (card == end_cards[i]) {\n\t\t\treturn true;\n\t\t}\n\t}\n\treturn false;\n}"
        else:
            fileContents += "const char* get_title_text() {\n\treturn title;\n}\n\nconst char* get_page_section(uint8_t page, uint8_t section) {\n\treturn page_text[page][section];\n}\n\nconst uint8_t get_num_pages() {\n\treturn num_pages;\n}\n\nconst uint8_t get_num_sections(uint8_t page) {\n\treturn num_sections[page];\n}\n\nconst uint8_t get_num_transitions(uint8_t page) {\n\treturn num_transitions[page];\n}\n\nconst int8_t get_transition_destination(uint8_t page, uint8_t transition) {\n\treturn -1;\n}\n\nconst char* get_page_transition(uint8_t page, uint8_t num) {\n\treturn \"ERROR: NO TRANSITION\";\n}\n\nbool is_end_card(uint8_t card) {\n\tfor (int i = 0; i < num_end_cards; ++i) {\n\t\tif (card == end_cards[i]) {\n\t\t\treturn true;\n\t\t}\n\t}\n\treturn false;\n}"

        file.write(fileContents)
        file.close()

# Read file contents
textFile = open(sys.argv[1], 'r')
textFileContents = textFile.readlines()
textFile.close()

# Do the parse
parser = TextParser()
parser.parseTextFile(textFileContents)

# Write to file
parser.writeStoryToC("src/story.c")