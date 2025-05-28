// import { Injectable, NotFoundException } from '@nestjs/common';
// import { InjectModel } from '@nestjs/mongoose';
// import { Chatroom, ChatroomDocument } from './chatroom.schema';
// import { Model, Types } from 'mongoose';
// import { Message, MessageDocument } from './message.schema';
// import { CreateMessageDto } from './dto/create-message.dto';

// @Injectable()
// export class ChatService {
//   constructor(
//     @InjectModel(Chatroom.name) private chatRoomModel: Model<ChatroomDocument>,
//     @InjectModel(Message.name) private messageModel: Model<MessageDocument>,
//   ) {}

//   async createChatRoom(
//     participants: Types.ObjectId[],
//     isGroup = false,
//     name?: string,
//   ) {
//     if (!isGroup && participants.length === 2) {
//       // Kiểm tra nếu phòng chat 1-1 đã tồn tại
//       const existingRoom = await this.chatRoomModel.findOne({
//         is_group: false,
//         participants: { $all: participants, $size: 2 },
//       });

//       if (existingRoom) {
//         return existingRoom; // Trả về phòng đã tồn tại
//       }
//     }

//     const room = new this.chatRoomModel({
//       participants,
//       is_group: isGroup,
//       name: isGroup ? name : undefined,
//       create_at: new Date(),
//     });

//     return await room.save();
//   }

//   async sendMessage(dto: CreateMessageDto, senderId: Types.ObjectId) {
//     const { chat_room_id, content } = dto;
//     const room = await this.chatRoomModel.findById(chat_room_id);
//     if (!room) {
//       throw new NotFoundException('Phòng chat không tồn tại');
//     }

//     const message = new this.messageModel({
//       chat_room_id,
//       sender_id: senderId,
//       content,
//       is_read: false,
//     });
//     return await message.save();
//   }
//   async getMessages(chatRoomId: Types.ObjectId) {
//     return this.messageModel
//       .find({ chat_room_id: chatRoomId })
//       .populate('sender_id', 'name email')
//       .sort({ createdAt: 1 })
//       .exec();
//   }

//   // async markMessagesAsRead(chatRoomId: Types.ObjectId, userId: Types.ObjectId) {
//   //   await this.messageModel.updateMany(
//   //     {
//   //       chat_room_id: chatRoomId,
//   //       sender_id: { $ne: userId },
//   //       is_read: false,
//   //     },
//   //     { $set: { is_read: true } },
//   //   );
//   //   return {
//   //     message: 'Đã đánh dấu đã đọc',
//   //   };
//   // }

//   async markMessagesAsRead(chatRoomId: Types.ObjectId, userId: Types.ObjectId) {
//     const result = await this.messageModel.updateMany(
//       {
//         chat_room_id: chatRoomId,
//         sender_id: { $ne: userId },
//         is_read: false,
//       },
//       { $set: { is_read: true } },
//     );

//     console.log('Update result:', result);

//     return {
//       message: 'Đã đánh dấu đã đọc',
//       matched: result.matchedCount,
//       modified: result.modifiedCount,
//     };
//   }

//   async getUserChatRoomsAndMessages(userId: Types.ObjectId) {
//     const chatRooms = await this.chatRoomModel
//       .find({ participants: userId })
//       .populate('participants', 'name email')
//       .sort({ create_at: -1 })
//       .lean();
//     const results = await Promise.all(
//       chatRooms.map(async (room) => {
//         const messages = await this.messageModel
//           .find({ chat_room_id: room._id })
//           .populate('sender_id', 'name email')
//           .sort({ createdAt: 1 })
//           .lean();

//         return {
//           room,
//           messages,
//         };
//       }),
//     );

//     return results;
//   }

//   async deleteChatRoom(chatRoomId: Types.ObjectId) {
//     await this.messageModel.deleteMany({ chat_room_id: chatRoomId });
//     await this.chatRoomModel.findByIdAndDelete(chatRoomId);
//     return { message: 'Phòng chat đã bị xoá' };
//   }

//   async getAllChatRooms(): Promise<Chatroom[]> {
//     return this.chatRoomModel
//       .find()
//       .populate('user1', 'fullName email role')
//       .populate('user2', 'fullName email role')
//       .sort({ updatedAt: -1 });
//   }
// }
// src/chat/chat.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';

import { Model, Types } from 'mongoose';
import { Chatroom, ChatroomDocument } from './chatroom.schema';
import { Message, MessageDocument } from './message.schema';

@Injectable()
export class ChatService {
  constructor(
    @InjectModel(Chatroom.name)
    private readonly chatroomModel: Model<ChatroomDocument>,
    @InjectModel(Message.name)
    private readonly messageModel: Model<MessageDocument>,
  ) { }

  async getUserChatrooms(userId: string): Promise<Chatroom[]> {
    return this.chatroomModel
      .find({ participants: new Types.ObjectId(userId) })
      .populate('participants', '-password') // loại bỏ thông tin nhạy cảm
      .sort({ create_at: -1 })
      .exec();
  }

  async getMessagesByRoom(chatRoomId: string): Promise<Message[]> {
    const roomExists = await this.chatroomModel.exists({ _id: chatRoomId });
    if (!roomExists) {
      throw new NotFoundException('Chat room not found');
    }

    return this.messageModel
      .find({ chat_room_id: chatRoomId })
      .populate('sender_id', 'email name') // nếu cần thêm thông tin người gửi
      .sort({ createdAt: 1 })
      .exec();
  }

  async createMessage(
    chatRoomId: string,
    senderId: string,
    content: string,
  ): Promise<Message> {
    return this.messageModel.create({
      chat_room_id: new Types.ObjectId(chatRoomId),
      sender_id: new Types.ObjectId(senderId),
      content,
    });
  }
}
