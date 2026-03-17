// -------------------------------------------------------------------------- //
// Author: Tancredi-Paul Grozav <paul@grozav.info>
// -------------------------------------------------------------------------- //
#include <cstring>

#include <fstream>
#include <string>
#include <sstream>
#include <vector>

#include <curl/curl.h>

using namespace ::std;

//—————————————————————————-//
class base64
{
private:
static const std::string BASE64_CHARS;
public:
static inline bool is_base64(unsigned char c);
static ::std::string base64_encode(unsigned char const* bytes_to_encode,
unsigned int in_len);
static ::std::string base64_decode(::std::string const& encoded_string);
};
const ::std::string base64::BASE64_CHARS =
"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789+/";
bool base64::is_base64(unsigned char c) {
return (isalnum(c) || (c == ‘+’) || (c == ‘/’));
}
::std::string base64::base64_encode(unsigned char const* bytes_to_encode,
unsigned int in_len)
{
::std::string ret;
int i = 0;
int j = 0;
unsigned char char_array_3[3];
unsigned char char_array_4[4];

while (in_len–)
{
char_array_3[i++] = *(bytes_to_encode++);
if (i == 3)
{
char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
char_array_4[1] = static_cast<unsigned char>(
((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4));
char_array_4[2] = static_cast<unsigned char>(
((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6));
char_array_4[3] = char_array_3[2] & 0x3f;

for(i = 0; (i <4) ; i++)
{
ret += BASE64_CHARS[char_array_4[i]];
}
i = 0;
}
}

if (i)
{
for(j = i; j < 3; j++)
{
char_array_3[j] = ‘\0’;
}

char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
char_array_4[1] = static_cast<unsigned char>(
((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4));
char_array_4[2] = static_cast<unsigned char>(
((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6));
char_array_4[3] = char_array_3[2] & 0x3f;

for (j = 0; (j < i + 1); j++)
{
ret += BASE64_CHARS[char_array_4[j]];
}

while((i++ < 3))
{
ret += ‘=’;
}
}
return ret;
}
::std::string base64::base64_decode(::std::string const& encoded_string)
{
int in_len = static_cast<int>(encoded_string.size());
int i = 0;
int j = 0;
size_t in_ = 0;
unsigned char char_array_4[4], char_array_3[3];
::std::string ret;

while (in_len– && (encoded_string[in_] != ‘=’) &&
is_base64(static_cast<unsigned char>(encoded_string[in_])))
{
char_array_4[i++] = static_cast<unsigned char>(encoded_string[in_]);
in_++;
if (i ==4)
{
for (i = 0; i <4; i++)
{
char_array_4[i] = static_cast<unsigned char>(BASE64_CHARS.find(
static_cast<char>(char_array_4[i])));
}

char_array_3[0] = static_cast<unsigned char>((char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4));
char_array_3[1] = static_cast<unsigned char>(((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2));
char_array_3[2] = static_cast<unsigned char>(((char_array_4[2] & 0x3) << 6) + char_array_4[3]);

for (i = 0; (i < 3); i++)
{
ret += static_cast<char>(char_array_3[i]);
}
i = 0;
}
}

if (i)
{
for (j = i; j <4; j++)
{
char_array_4[j] = 0;
}

for (j = 0; j <4; j++)
{
char_array_4[j] = static_cast<unsigned char>(BASE64_CHARS.find(
static_cast< char>(char_array_4[j])));
}

char_array_3[0] = static_cast<unsigned char>((char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4));
char_array_3[1] = static_cast<unsigned char>(((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2));
char_array_3[2] = static_cast<unsigned char>(((char_array_4[2] & 0x3) << 6) + char_array_4[3]);

for (j = 0; (j < i – 1); j++)
{
ret += static_cast<char>(char_array_3[j]);
}
}
return ret;
}
//—————————————————————————-//

//—————————————————————————-//
class curl_email
{
public:
struct contact
{
::std::string name;
::std::string email;
};
typedef ::std::vector< contact > recipients;

private:
struct upload_status {
int lines_read = 0;
::std::vector<::std::string> *mail_content = nullptr;
};
recipients rcpts;
contact from;
::std::vector<::std::string> mail_content;
static size_t payload_source(void *ptr, size_t size, size_t nmemb,
void *userp);

public:
void set_recipients(const recipients &recipients);
void add_field(const ::std::string &key, const ::std::string &value);
void add_empty_field();
void add_to(const contact &to);
void add_cc(const contact &cc);
void add_from(const contact &from);
void add_subject(const ::std::string &subject);
void add_data(const ::std::string &data);
int send();
};
size_t curl_email::payload_source(void *ptr, size_t size, size_t nmemb,
void *userp)
{
struct upload_status *upload_ctx = static_cast<struct upload_status *>(userp);
::std::vector<::std::string> &mail_content = *(upload_ctx->mail_content);
const char *data;

if((size == 0) || (nmemb == 0) || ((size*nmemb) < 1))
{
return 0;
}

if(mail_content.size()>static_cast<unsigned int>(upload_ctx->lines_read))
{
data = mail_content[static_cast<size_t>(upload_ctx->lines_read)].c_str();
size_t len = strlen(data);
memcpy(ptr, data, len);
upload_ctx->lines_read++;
// len should not be larger than size*nmemb
return len;
}
return 0;
}
void curl_email::set_recipients(const recipients &recipients)
{
this->rcpts = recipients;
}
void curl_email::add_field(const ::std::string &key, const ::std::string &value)
{
this->mail_content.push_back(key+": "+value+"\r\n");
}
void curl_email::add_empty_field()
{
this->mail_content.push_back("\r\n");
}
void curl_email::add_to(const contact &to)
{
this->add_field("To", to.name+" <"+to.email+">");
}
void curl_email::add_cc(const contact &cc)
{
this->add_field("Cc", cc.name+" <"+cc.email+">");
}
void curl_email::add_from(const contact &from)
{
this->from = from;
this->add_field("From", from.name+" <"+from.email+">");
}
void curl_email::add_subject(const ::std::string &subject)
{
this->from = from;
this->add_field("Subject", subject);
}
void curl_email::add_data(const ::std::string &data)
{
this->mail_content.push_back(data+"\r\n");
}
int curl_email::send()
{
CURL *curl;
CURLcode res = CURLE_OK;
struct curl_slist *recipients = NULL;
struct upload_status upload_ctx;

upload_ctx.mail_content = &(this->mail_content);

curl = curl_easy_init();
if(curl) {
/* This is the URL for your mailserver */
curl_easy_setopt(curl, CURLOPT_URL, "smtp://mail.example.com");

/* Note that this option isn’t strictly required, omitting it will result
* in libcurl sending the MAIL FROM command with empty sender data. All
* autoresponses should have an empty reverse-path, and should be directed
* to the address in the reverse-path which triggered them. Otherwise,
* they could cause an endless loop. See RFC 5321 Section 4.5.5 for more
* details.
*/
curl_easy_setopt(curl, CURLOPT_MAIL_FROM, from.email.c_str());

/* Add two recipients, in this particular case they correspond to the
* To: and Cc: addressees in the header, but they could be any kind of
* recipient. */
for(recipients::iterator it = rcpts.begin(); it != rcpts.end(); it++)
{
recipients = curl_slist_append(recipients, it->email.c_str());
}
curl_easy_setopt(curl, CURLOPT_MAIL_RCPT, recipients);

/* We’re using a callback function to specify the payload (the headers and
* body of the message). You could just use the CURLOPT_READDATA option to
* specify a FILE pointer to read from. */
curl_easy_setopt(curl, CURLOPT_READFUNCTION, payload_source);
curl_easy_setopt(curl, CURLOPT_READDATA, &upload_ctx);
curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);

/* Send the message */
res = curl_easy_perform(curl);

/* Check for errors */
if(res != CURLE_OK)
{
fprintf(stderr, "curl_easy_perform() failed: %s\n",
curl_easy_strerror(res));
}

/* Free the list of recipients */
curl_slist_free_all(recipients);

/* curl won’t send the QUIT command until you call cleanup, so you should
* be able to re-use this connection for additional messages (setting
* CURLOPT_MAIL_FROM and CURLOPT_MAIL_RCPT as required, and calling
* curl_easy_perform() again. It may not be a good idea to keep the
* connection open for a very long time though (more than a few minutes
* may result in the server timing out the connection), and you do want to
* clean up in the end.
*/
curl_easy_cleanup(curl);
}

return static_cast<int>(res);
}
//—————————————————————————-//

int main()
{
  typedef curl_email::contact rec;
  rec pg{"Tancredi-Paul Grozav", "paul@example.com"};
  curl_email ce;
  ce.set_recipients({pg});
  ce.add_to(pg);
  ce.add_from(pg);
  ce.add_subject("Test");
  ce.add_field("Date", "Wed, 20 Dec 2017 16:45:43 +0200");
  ce.add_field("MIME-Version", "1.0");

  ::std::string boundary = "————–231BDD24AA49E9F331EE4B89";
  ce.add_field("Content-Type", "multipart/mixed; boundary=\""+boundary+"\"");
  ce.add_empty_field();
  ce.add_data("–"+boundary);
  ce.add_field("Content-Type", "text/html; charset=\"ISO-8859-1\"");
  ce.add_field("Content-Transfer-Encoding", "7bit");
  ce.add_empty_field();
  ce.add_data("<b>The</b> <a href=\"http://paul.grozav.info\">message</a>.");
  ce.add_empty_field();
  ce.add_empty_field();

  bool has_attachment = true;
  if(has_attachment)
  {
    string file_name = "20170823.pdf";
    ce.add_data("–"+boundary);
    ce.add_field("Content-Type", "image/pdf; name=\""+file_name+"\"");
    ce.add_field("Content-Transfer-Encoding", "base64");
    ce.add_field("Content-Disposition", "attachment; filename=\""+file_name+"\"");
    ce.add_empty_field();
    ::std::ifstream file("/home/paul/Documents/"+file_name);
    if(file.is_open())
    {
      ::std::stringstream buffer;
      buffer << file.rdbuf();
      file.close();
      ::std::string file_content = buffer.str();
      file_content = base64::base64_encode(
        reinterpret_cast<const unsigned char*>(file_content.c_str())
        , static_cast<unsigned int>(file_content.size()));
      // you have to split file in chunks and add it to mail. libcurl has max
      // size. See https://curl.haxx.se/mail/lib-2013-04/0324.html
      size_t file_size = file_content.size();
      const unsigned int chunk_size = 15000;
      for(unsigned int i=0; i< file_size; i+=chunk_size)
      {
        if(i+chunk_size < file_size)
        {
          ce.add_data(file_content.substr(i, chunk_size));
        }else{
          ce.add_data(file_content.substr(i, file_size-i));
        }
      }
    }
  }
  ce.add_data("–"+boundary+"–");
  ce.send();
  return EXIT_SUCCESS;
}
// -------------------------------------------------------------------------- //
