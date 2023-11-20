//
// Created by yangbin on 2022/1/11.
//

#ifndef DESKTOP_MULTI_WINDOW_WINDOWS_MULTI_WINDOW_MANAGER_H_
#define DESKTOP_MULTI_WINDOW_WINDOWS_MULTI_WINDOW_MANAGER_H_

#include <cstdint>
#include <string>
#include <map>

#include "base_flutter_window.h"
#include "flutter_window.h"

class MultiWindowManager : public std::enable_shared_from_this<MultiWindowManager>, public FlutterWindowCallback {

 public:
  static MultiWindowManager *Instance();

  MultiWindowManager();

  int Create(std::string args);

  void AttachFlutterMainWindow(HWND main_window_handle, std::unique_ptr<WindowChannel> window_channel);

  void Show(int id);

  void Hide(int id);

  void Close(int id);

  void Destroy(int id);

  void SetFrame(int id, double_t x, double_t y, double_t width, double_t height);

  void SetClosable(int id, bool closable);

  void SetMinimumSize(int id, double_t width, double_t height);

  void Center(int id);

  void SetTitle(int id, const std::string &title);

  std::vector<int> GetAllSubWindowIds();

  void OnWindowClose(int id) override;

  void OnWindowDestroy(int id) override;

 private:

  std::map<int, std::unique_ptr<BaseFlutterWindow>> windows_;

  void HandleWindowChannelCall(
      int from_window_id,
      int target_window_id,
      const std::string &call,
      flutter::EncodableValue *arguments,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result
  );

};

#endif //DESKTOP_MULTI_WINDOW_WINDOWS_MULTI_WINDOW_MANAGER_H_
